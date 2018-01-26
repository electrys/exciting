module mod_wfint
  use modmain
  use mod_wannier
  use m_plotmat
  implicit none

! module variables
  type( k_set) :: wfint_kset                        ! k-point set on which the interpolation is performed
  type( Gk_set) :: wfint_Gkset                      ! G+k-point set on which the interpolation is performed
  logical :: wfint_initialized = .false.
  real(8) :: wfint_efermi                           ! interpolated fermi energy

  real(8), allocatable :: wfint_eval(:,:)           ! interpolated eigenenergies
  complex(8), allocatable :: wfint_evec(:,:,:)      ! interpolated eigenvectors
  complex(8), allocatable :: wfint_transform(:,:,:) ! corresponding expansion coefficients
  real(8), allocatable :: wfint_occ(:,:)            ! interpolated occupation numbers
  real(8), allocatable :: wfint_phase(:,:)          ! summed phase factors in interpolation
  complex(8), allocatable :: wfint_pkr(:,:)
  complex(8), allocatable :: wfint_pqr(:,:)

  ! R vector set
  integer :: wfint_nrpt
  integer, allocatable :: wfint_rvec(:,:)
  integer, allocatable :: wfint_rmul(:)
  integer, allocatable :: wfint_wdistvec(:,:,:,:,:)
  integer, allocatable :: wfint_wdistmul(:,:,:)

! methods
  contains
    !BOP
    ! !ROUTINE: wfint_init
    ! !INTERFACE:
    !
    subroutine wfint_init( int_kset, evalin_)
      ! !USES:
        use m_getunit 
      ! !INPUT PARAMETERS:
      !   int_kset : k-point set on which the interpolation is performed on (in, type k_set)
      ! !DESCRIPTION:
      !   Sets up the interpolation grid and calculates the interpolated eigenenergies as well as 
      !   the corresponding expansion coefficients and phasefactors for the interpolated wavefunctions.
      !
      ! !REVISION HISTORY:
      !   Created July 2017 (SeTi)
      !EOP
      !BOC
      type( k_set), intent( in) :: int_kset
      real(8), optional, intent( in) :: evalin_( wf_fst:wf_lst, wf_kset%nkpt)
    
      integer :: ik, ist, un, recl, nkpqp, fstqp, lstqp, nk, isym, iq, nkequi, isymequi( wf_kset%nkpt), ikequi( wf_kset%nkpt)
      real(8) :: vl(3), efermiqp, efermiks
      character(256) :: fname, fxt
      logical :: exist
      real(8), allocatable :: evalfv(:,:), evalinks(:,:), evalinqp(:,:), evalqp(:), evalks(:)
      complex(8), allocatable :: evecqp(:,:,:), auxmat(:,:)

      if( wfint_initialized) call wfint_destroy

      wfint_kset = int_kset
    
      allocate( evalinks( wf_fst:wf_lst, wf_kset%nkpt))
      allocate( evalinqp( wf_fst:wf_lst, wf_kset%nkpt))
    
      if( .true. .and. wf_disentangle) then
        evalinks = 0.d0
        do ist = 1, wf_nwf
          evalinks( wf_fst+ist-1, :) = wf_sub_eval( ist, :)
        end do
      else
        if( present( evalin_)) then
          evalinks = evalin_
          !do ik = 1, wf_kset%nkpt
          !  write(*,'(I,1000F13.6)') ik, evalin( :, ik)
          !end do
        else
          !if( input%properties%wannier%input .eq. "gw") then
          !  call getunit( un)
          !  write( fname, '("EVALQP.OUT")')
          !  inquire( file=trim( fname), exist=exist)
          !  if( .not. exist) then
          !    write( *, '("Error (wfint_init): File EVALQP.OUT does not exist!")')
          !    call terminate
          !  end if
          !  inquire( iolength=recl) nkpqp, fstqp, lstqp
          !  open( un, file=trim( fname), action='read', form='unformatted', access='direct', recl=recl)
          !  read( un, rec=1), nkpqp, fstqp, lstqp
          !  close( un)
          !  if( fstqp .gt. wf_fst) then
          !    write( *, '("Error (wfint_init): First QP band (",I3,") is greater than first wannierized band (",I3,").")') fstqp, wf_fst
          !    call terminate
          !  end if
          !  if( lstqp .lt. wf_lst) then
          !    write( *, '("Error (wfint_init): Last QP band (",I3,") is less than last wannierized band (",I3,").")') lstqp, wf_lst
          !    call terminate
          !  end if
          !  allocate( evalqp( fstqp:lstqp))
          !  allocate( evalks( fstqp:lstqp))

          !  fxt = filext
          !  write( filext, '("_GW.OUT")')
          !  call readfermi
          !  filext = fxt
          !  call getunit( un)
          !  inquire( iolength=recl) nkpqp, fstqp, lstqp, vl, evalqp, evalks!, efermiqp, efermiks
          !  open( un, file=trim( fname), action='read', form='unformatted', access='direct', recl=recl)
          !  do ik = 1, nkpqp
          !    read( un, rec=ik) nk, fstqp, lstqp, vl, evalqp, evalks!, efermiqp, efermiks
          !    call findequivkpt( vl, wf_kset, nkequi, isymequi, ikequi)
          !    do iq = 1, nkequi
          !      ! energies in EVALQP are already shifted
          !      evalinqp( :, ikequi( iq)) = evalqp( wf_fst:wf_lst)! + efermi
          !      evalinks( :, ikequi( iq)) = evalks( wf_fst:wf_lst)
          !    end do
          !  end do
          !  close( un)
          !  deallocate( evalqp, evalks)
          !else
          !  allocate( evalfv( nstfv, nspnfv))
          !  do ik = 1, wf_kset%nkpt
          !    call getevalfv( wf_kset%vkl( :, ik), evalfv)
          !    evalinks( :, ik) = evalfv( wf_fst:wf_lst, 1)
          !  end do
          !  deallocate( evalfv)
          !end if
          call wannier_geteval( evalfv, fstqp, lstqp)
          evalinks = evalfv( wf_fst:wf_lst, :)
        end if
      end if
    
      call wfint_rvectors

      allocate( wfint_eval( wf_nwf, wfint_kset%nkpt))
      allocate( wfint_transform( wf_nwf, wf_nwf, wfint_kset%nkpt))
      
      if( input%properties%wannier%input .eq. "gw") then
        ! new version. Correct sorted
        !allocate( evecqp( wf_fst:wf_lst, wf_fst:wf_lst, wfint_kset%nkpt))
        !allocate( auxmat( wf_fst:wf_lst, wf_fst:wf_lst))
        !call wfint_interpolate_eigsys( evalinqp)
        !deallocate( evalinqp)
        !allocate( evalinqp( wf_fst:wf_lst, wfint_kset%nkpt))
        !evecqp = wfint_transform
        !evalinqp = wfint_eval
        !call wfint_interpolate_eigsys( evalinks)
        !do ik = 1, wfint_kset%nkpt
        !  call zgemm( 'c', 'n', wf_nwf, wf_nwf, wf_nwf, zone, &
        !       wfint_transform( :, :, ik), wf_nwf, &
        !       evecqp( :, :, ik), wf_nwf, zzero, &
        !       auxmat, wf_nwf)
        !  call dgemv( 'n', wf_nwf, wf_nwf, 1.d0, &
        !       abs( auxmat)**2, wf_nwf, &
        !       evalinqp( :, ik), 1, 0.d0, &
        !       wfint_eval( :, ik), 1)
        !end do
        !deallocate( evecqp, auxmat)

        ! old version. Energy sorted
        call wfint_interpolate_eigsys( evalinks)
      else
        call wfint_interpolate_eigsys( evalinks)
      end if
    
      wfint_initialized = .true.
      deallocate( evalinks, evalinqp)

      return
    end subroutine wfint_init
    !EOC

!--------------------------------------------------------------------------------------
    
    !BOP
    ! !ROUTINE: wfint_init
    ! !INTERFACE:
    !
    subroutine wfint_destroy
      ! !USES:
      ! !INPUT PARAMETERS:
      !   int_kset : k-point set on which the interpolation is performed on (in, type k_set)
      ! !DESCRIPTION:
      !   Sets up the interpolation grid and calculates the interpolated eigenenergies as well as 
      !   the corresponding expansion coefficients and phasefactors for the interpolated wavefunctions.
      !
      ! !REVISION HISTORY:
      !   Created July 2017 (SeTi)
      !EOP
      !BOC
    
      if( allocated( wfint_phase)) deallocate( wfint_phase)
      if( allocated( wfint_pkr)) deallocate( wfint_pkr)
      if( allocated( wfint_pqr)) deallocate( wfint_pqr)
      if( allocated( wfint_eval)) deallocate( wfint_eval)
      if( allocated( wfint_evec)) deallocate( wfint_evec)
      if( allocated( wfint_transform)) deallocate( wfint_transform)
      if( allocated( wfint_occ)) deallocate( wfint_occ)
      wfint_initialized = .false.
      return
    end subroutine wfint_destroy
    !EOC

!--------------------------------------------------------------------------------------
    
    !BOP
    ! !ROUTINE: wfint_init
    ! !INTERFACE:
    !
    subroutine wfint_rvectors
      ! !USES:
      ! !INPUT PARAMETERS:
      !   int_kset : k-point set on which the interpolation is performed on (in, type k_set)
      ! !DESCRIPTION:
      !   Finds R vectors in the Wigner-Seitz supercell centered around the origin. 
      !
      ! !REVISION HISTORY:
      !   Created July 2017 (SeTi)
      !EOP
      !BOC
      integer :: i, j, k, is, js, ks, ir, iv(3), ik, iq, cnt
      integer :: tmpvec( 3, 2*wf_kset%nkpt), tmpmul( 2*wf_kset%nkpt), nequiv, iequiv( wf_kset%nkpt)
      real(8) :: v1(3), v2(3), vl(3), rv(3), vs(3), vc(3), d, dist(125)
      real(8) :: latvec(3,3), ilatvec(3,3)
      logical :: contained
      complex(8) :: ftwgt

      complex(8), allocatable :: auxmat(:,:)
    
      latvec = input%structure%crystal%basevect
      call r3minv( latvec, ilatvec)

      !write(*,*) "start"
      tmpvec = 0
      tmpmul = 0
      ! map R vectors from canonical SZ into its Wigner-Seitz cell
      ! and count equivalent vectors
      wfint_nrpt = 0
      do i = -wf_kset%ngridk(1), wf_kset%ngridk(1)
        v1 = i*input%structure%crystal%basevect( :, 1)
        do j = -wf_kset%ngridk(2), wf_kset%ngridk(2)
          v2 = v1 + j*input%structure%crystal%basevect( :, 2)
          do k = -wf_kset%ngridk(3), wf_kset%ngridk(3)
            vc = v2 + k*input%structure%crystal%basevect( :, 3)
            cnt = 0
            do is = -2, 2               
              do js = -2, 2             
                do ks = -2, 2           
                  cnt = cnt + 1
                  call r3mv( latvec, dble( (/is, js, ks/)*wf_kset%ngridk), vs)
                  dist( cnt) = norm2( vc - vs)
                end do
              end do
            end do
            d = minval( dist)
            if( abs( dist( 63) - d) .lt. input%structure%epslat) then
              wfint_nrpt = wfint_nrpt + 1
              do ir = 1, 125
                if( abs( dist( ir) - d) .lt. input%structure%epslat) tmpmul( wfint_nrpt) = tmpmul( wfint_nrpt) + 1
              end do
              tmpvec( :, wfint_nrpt) = (/i, j, k/)
            end if
          end do
        end do
      end do

      if( allocated( wfint_rvec)) deallocate( wfint_rvec)
      allocate( wfint_rvec( 3, wfint_nrpt))
      if( allocated( wfint_rmul)) deallocate( wfint_rmul)
      allocate( wfint_rmul( wfint_nrpt))

      do ir = 1, wfint_nrpt
        wfint_rvec( :, ir) = tmpvec( :, ir)
        wfint_rmul( ir) = tmpmul( ir)
        call r3mv( latvec, dble( wfint_rvec( :, ir)), vc)
      end do

      !write(*,*) "R vectors found"
      if( allocated( wfint_wdistvec)) deallocate( wfint_wdistvec)
      allocate( wfint_wdistvec( 3, 8, wf_nwf, wf_nwf, wfint_nrpt))
      if( allocated( wfint_wdistmul)) deallocate( wfint_wdistmul)
      allocate( wfint_wdistmul( wf_nwf, wf_nwf, wfint_nrpt))

      wfint_wdistvec = 0
      wfint_wdistmul = 0
#ifdef USEOMP
!$omp parallel default( shared) private( ir, j, i, vc, v1, d, is, js, ks, vs, vl)
!$omp do collapse( 3)
#endif
      do ir = 1, wfint_nrpt
        do j = 1, wf_nwf
          do i = 1, wf_nwf
            call r3mv( latvec, dble( wfint_rvec( :, ir)), vc)
            vc = wf_centers( :, j) + vc - wf_centers( :, i)
            v1 = vc
            d = norm2( vc)
            ! map to WS cell
            do is = -2, 2    
              do js = -2, 2             
                do ks = -2, 2           
                  call r3mv( latvec, dble( (/is, js, ks/)*wf_kset%ngridk), vs)
                  if( norm2( vc - vs) .lt. d) then
                    d = norm2( vc - vs)
                    v1 = vc - vs
                  end if
                end do
              end do
            end do
            vc = v1
            ! find equivalent vectors
            do is = -2, 2    
              do js = -2, 2             
                do ks = -2, 2           
                  call r3mv( latvec, dble( (/is, js, ks/)*wf_kset%ngridk), vs)
                  if( abs( norm2( vc - vs) - d) .lt. input%structure%epslat) then
                    wfint_wdistmul( i, j, ir) = wfint_wdistmul( i, j, ir) + 1
                    v1 = vc - vs + wf_centers( :, i) - wf_centers( :, j)
                    call r3mv( ilatvec, v1, vl)
                    wfint_wdistvec( :, wfint_wdistmul( i, j, ir), i, j, ir) = nint( vl)
                  end if
                end do
              end do
            end do
          end do
        end do
      end do
#ifdef USEOMP
!$omp end do
!$omp end parallel
#endif
      !write(*,*) "shortest distances found"

      ! precompute phases for Fourier sums
      if( allocated( wfint_phase)) deallocate( wfint_phase)
      allocate( wfint_phase( wf_kset%nkpt, wfint_kset%nkpt))
      if( allocated( wfint_pkr)) deallocate( wfint_pkr)
      allocate( wfint_pkr( wf_kset%nkpt, wfint_nrpt))
      if( allocated( wfint_pqr)) deallocate( wfint_pqr)
      allocate( wfint_pqr( wfint_kset%nkpt, wfint_nrpt))

      do ir = 1, wfint_nrpt
        do ik = 1, wf_kset%nkpt
          d = twopi*dot_product( wf_kset%vkl( :, ik), dble( wfint_rvec( :, ir)))
          wfint_pkr( ik, ir) = cmplx( cos( d), sin( d), 8)
        end do
        do iq = 1, wfint_kset%nkpt
          d = twopi*dot_product( wfint_kset%vkl( :, iq), dble( wfint_rvec( :, ir)))
          wfint_pqr( iq, ir) = cmplx( cos( d), sin( d), 8)/dble( wfint_rmul( ir))
        end do
      end do

      allocate( auxmat( wfint_kset%nkpt, wf_kset%nkpt))
      call zgemm( 'n', 'c', wfint_kset%nkpt, wf_kset%nkpt, wfint_nrpt, zone, &
             wfint_pqr, wfint_kset%nkpt, &
             wfint_pkr, wf_kset%nkpt, zzero, &
             auxmat, wfint_kset%nkpt)
      wfint_phase = dble( transpose( auxmat))/wf_kset%nkpt
      deallocate( auxmat)
      !write(*,*) "phases calculated"

      return
    end subroutine wfint_rvectors
    !EOC

!--------------------------------------------------------------------------------------
    
    !BOP
    ! !ROUTINE: wfint_interpolate_eigsys
    ! !INTERFACE:
    !
    subroutine wfint_interpolate_eigsys( evalin)
      ! !USES:
      use m_wsweight
      ! !INPUT PARAMETERS:
      !   evalin : eigenenergies on original grid (in, real( wf_fst:wf_lst, wf_kset%nkpt))
      ! !DESCRIPTION:
      !   Calculates the interpolated eigenenergies as well as the corresponding expansion 
      !   coefficients and phasefactors for the interpolated wavefunctions.
      !
      ! !REVISION HISTORY:
      !   Created July 2017 (SeTi)
      !EOP
      !BOC

      real(8), intent( in) :: evalin( wf_fst:wf_lst, wf_kset%nkpt)
      
      integer :: nrpt, ix, iy, iz, ik, iq, ir
      real(8) :: dotp
      complex(8) :: ftweight
    
      complex(8), allocatable :: auxmat(:,:), auxmat2(:,:), ueu(:,:,:), hamilton(:,:,:), hamiltonr(:,:,:)

      !**********************************************
      ! interpolated eigenenergies and corresponding 
      ! eigenvectors in Wannier basis
      !**********************************************
    
      ! calculate Hamlitonian matrix elements in Wannier representation 
      allocate( ueu( wf_nwf, wf_nwf, wf_kset%nkpt))
#ifdef USEOMP
!$omp parallel default( shared) private( ik, iy, auxmat)
#endif
      allocate( auxmat( wf_nwf, wf_nwf))
#ifdef USEOMP
!$omp do
#endif
      do ik = 1, wf_kset%nkpt
        auxmat = zzero
        do iy = 1, wf_nwf
          auxmat( iy, :) = wf_transform( iy, :, ik)*evalin( wf_fst+iy-1, ik)
        end do
        call zgemm( 'c', 'n', wf_nwf, wf_nwf, wf_nwf, zone, &
               wf_transform( :, :, ik), wf_nwf, &
               auxmat, wf_nwf, zzero, &
               ueu( :, :, ik), wf_nwf)
      end do
#ifdef USEOMP
!$omp end do
#endif
      deallocate( auxmat)
#ifdef USEOMP
!$omp end parallel
#endif
    
      ! calculate interpolated Hamiltonian
      allocate( hamilton( wf_nwf, wf_nwf, wfint_kset%nkpt))
      allocate( hamiltonr( wf_nwf, wf_nwf, wfint_nrpt))

#ifdef USEOMP
!!$OMP PARALLEL DEFAULT(SHARED) PRIVATE( iy)
!!$OMP DO
#endif
      do iy = 1, wf_nwf
        call zgemm( 'n', 'n', wf_nwf, wfint_kset%nkpt, wf_kset%nkpt, zone, &
             ueu( iy, :, :), wf_nwf, &
             cmplx( wfint_phase, 0, 8), wf_kset%nkpt, zzero, &
             hamilton( iy, :, :), wf_nwf)
      end do
#ifdef USEOMP
!!$OMP END DO
!!$OMP END PARALLEL
#endif

!#ifdef USEOMP
!!$omp parallel default( shared) private( ir, ik)
!!$omp do
!#endif
!      do ir = 1, wfint_nrpt
!        hamiltonr( :, :, ir) = zzero
!        do ik = 1, wf_kset%nkpt
!          hamiltonr( :, :, ir) = hamiltonr( :, :, ir) + ueu( :, :, ik)*conjg( wfint_pkr( ik, ir))/wf_kset%nkpt
!        end do
!      end do
!#ifdef USEOMP
!!$omp end do
!!$omp end parallel
!#endif
!
!#ifdef USEOMP
!!$omp parallel default( shared) private( iq, ir, ix, iy, iz, dotp, ftweight)
!!$omp do
!#endif
!      do iq = 1, wfint_kset%nkpt
!        hamilton( :, :, iq) = zzero
!        do ir = 1, wfint_nrpt
!          do ix = 1, wf_nwf
!            do iy = 1, wf_nwf
!              ftweight = zzero
!              do iz = 1, wfint_wdistmul( ix, iy, ir)
!                dotp = twopi*dot_product( wfint_kset%vkl( :, iq), dble( wfint_wdistvec( :, iz, ix, iy, ir)))
!                ftweight = ftweight + cmplx( cos( dotp), sin( dotp), 8)
!              end do
!              hamilton( ix, iy, iq) = hamilton( ix, iy, iq) + ftweight/wfint_rmul( ir)/wfint_wdistmul( ix, iy, ir)*hamiltonr( ix, iy, ir)
!            end do
!          end do
!        end do
!      end do
!#ifdef USEOMP
!!$omp end do
!!$omp end parallel
!#endif
      deallocate( ueu, hamiltonr)
    
      ! diagonalize interpolated Hamiltonian
#ifdef USEOMP
!$omp parallel default( shared) private( iq)
!$omp do
#endif
      do iq = 1, wfint_kset%nkpt 
        call diaghermat( wf_nwf, hamilton( :, :, iq), wfint_eval( :, iq), wfint_transform( :, :, iq))
      end do
#ifdef USEOMP
!$omp end do
!$omp end parallel
#endif
      deallocate( hamilton)
    
      return
    end subroutine wfint_interpolate_eigsys
    !EOC

!--------------------------------------------------------------------------------------
    
    !BOP
    ! !ROUTINE: wfint_interpolate_occupancy
    ! !INTERFACE:
    !
    subroutine wfint_interpolate_occupancy
      ! !USES:
      use mod_eigenvalue_occupancy, only: occmax
      use mod_charge_and_moment, only: chgval
      ! !DESCRIPTION:
      !   Calclulates the interpolated occupation numbers for the wannierized bands and
      !   interpolated Fermi energy.
      !
      ! !REVISION HISTORY:
      !   Created July 2017 (SeTi)
      !EOP
      !BOC

      integer, parameter :: maxit = 1000
      
      integer :: iq, ist, nvm, it
      real(8) :: e0, e1, fermidos, chg, x, t1
      
      real(8) :: sdelta, stheta
      
      real(8), allocatable :: occ_tmp(:,:)
    
      allocate( wfint_occ( wf_nwf, wfint_kset%nkpt))
      allocate( occ_tmp( wf_lst, wfint_kset%nkpt))

      if( input%groundstate%stypenumber .ge. 0 ) then
        t1 = 1.d0/input%groundstate%swidth
        nvm = nint( chgval/occmax)
        if( (wf_fst .ne. 1) .and. (wf_fst .le. nvm)) then
          write( *, '(" Warning (wfint_interpolate_occupancy): The lowest wannierized band is ",I3,". All bands below are considered to be fully occupied.")') wf_fst
          occ_tmp( 1:(wf_fst-1), :) = occmax
        end if
        if( wf_fst .gt. nvm) then
          write( *, '(" Error (wfint_interpolate_occupancy): No valence bands have been wannierized. Occupancies cannot be determined.")')
          call terminate
        end if
        if( (wf_lst .le. nvm)) then
          write( *, '(" Error (wfint_interpolate_occupancy): At least one conduction band has to be wannierized in order to determine occupancies.")')
          call terminate
        end if
        ! check for insulator or semiconductor
        e0 = maxval( wfint_eval( nvm-wf_fst+1, :))
        e1 = minval( wfint_eval( nvm-wf_fst+2, :))
        wfint_efermi = 0.5*(e0 + e1)
        write(*,*) nvm, nvm-wf_fst+1, e0, e1
    
        fermidos = 0.d0
        chg = 0.d0
#ifdef USEOMP                
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE( iq, ist, x) reduction(+: chg, fermidos)
!$OMP DO  
#endif
        do iq = 1, wfint_kset%nkpt
          do ist = 1, wf_fst-1
            chg = chg + wfint_kset%wkpt( iq)*occ_tmp( ist, iq)
          end do
          do ist = 1, wf_nwf
            x = (wfint_eval( ist, iq) - wfint_efermi)*t1
            fermidos = fermidos + wfint_kset%wkpt( iq)*sdelta( input%groundstate%stypenumber, x)*t1
            occ_tmp( wf_fst+ist-1, iq) = occmax*stheta( input%groundstate%stypenumber, -x)
            chg = chg + wfint_kset%wkpt( iq)*occ_tmp( wf_fst+ist-1, iq)
          end do
        end do
#ifdef USEOMP
!$OMP END DO
!$OMP END PARALLEL
#endif
        fermidos = fermidos + occmax
        it = 0
        if( (e1 .ge. e0) .and. (abs( chg - chgval) .lt. input%groundstate%epsocc)) then
          write( *, '(" Info (wannier_interpolate_occupancy): System has gap. Simplistic method used in determining efermi and occupation")')
        else
        ! metal found
          e0 = wfint_eval( 1, 1)
          e1 = e0
          do ist = 1, wf_nwf
            e0 = min( e0, minval( wfint_eval( ist, :)))
            e1 = max( e1, maxval( wfint_eval( ist, :)))
          end do
    
          do while( it .lt. maxit)
            wfint_efermi = 0.5*(e0 + e1)
            chg = 0.d0
#ifdef USEOMP                
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE( iq, ist, x) reduction(+: chg)
!$OMP DO  
#endif
            do iq = 1, wfint_kset%nkpt
              do ist = 1, wf_fst-1
                chg = chg + wfint_kset%wkpt( iq)*occ_tmp( ist, iq)
              end do
              do ist = 1, wf_nwf
                x = (wfint_efermi - wfint_eval( ist, iq))*t1
                occ_tmp( wf_fst+ist-1, iq) = occmax*stheta( input%groundstate%stypenumber, x)
                chg = chg + wfint_kset%wkpt( iq)*occ_tmp( wf_fst+ist-1, iq)
              end do
            end do
#ifdef USEOMP
!$OMP END DO
!$OMP END PARALLEL
#endif
            if( chg .lt. chgval) then
              e0 = wfint_efermi
            else
              e1 = wfint_efermi
            end if
            if( (e1-e0) .lt. input%groundstate%epsocc) then
              it = maxit+1
            else
              it = it + 1
            end if
          end do
        end if
        if( it .eq. maxit) then
          write( *, '("Error (wfint_interpolate_occupancy): Fermi energy could not be found.")')
          call terminate
        end if
      else
        write( *, '("Error (wfint_interpolate_occupancy): Not implemented for this stype.")')
        call terminate
      end if

      wfint_occ(:,:) = occ_tmp( wf_fst:(wf_fst+wf_nwf-1), :)
      deallocate( occ_tmp)
    
      write(*,*) wfint_efermi

      return
    end subroutine wfint_interpolate_occupancy
    !EOC

!--------------------------------------------------------------------------------------

    !BOP
    ! !ROUTINE: wfint_interpolate_bandgap
    ! !INTERFACE:
    !
    subroutine wfint_interpolate_ederiv( velo_, mass_)
      real(8), intent( out) :: velo_( 3, wf_nwf, wfint_kset%nkpt)
      real(8), intent( out) :: mass_( 3, 3, wf_nwf, wfint_kset%nkpt)

      integer :: ik, iq, ir, ist, jst, d1, d2, ndeg, sdeg, ddeg
      real(8) :: eps1, eps2, vr(3), vk(3)
      complex(8) :: hamwr( wf_nwf, wf_nwf, wfint_nrpt), hamwk( wf_nwf, wf_nwf)
      complex(8) :: velo( wf_nwf, wf_nwf, 3, wfint_kset%nkpt)
      complex(8) :: dmat( wf_nwf, wf_nwf, 3, wfint_kset%nkpt)
      complex(8) :: mass( wf_nwf, wf_nwf, 3, 3, wfint_kset%nkpt)
      
      real(8), allocatable :: evalin(:,:), degeval(:)
      complex(8), allocatable :: auxmat(:,:), degmat(:,:), degevec(:,:), transform(:,:,:)

      real(8) :: r3mdet

      eps1 = 1.d-4
      eps2 = 1.d-3
      ddeg = 1

      velo_ = 0.d0
      mass_ = 0.d0

      call wannier_geteval( evalin, ist, jst)

      allocate( auxmat( wf_nwf, wf_nwf))
      allocate( transform( wf_nwf, wf_nwf, wfint_kset%nkpt))

      ! get R-dependent Hamiltonian in Wannier gauge
      hamwr = zzero
      do ik = 1, wf_kset%nkpt
        auxmat = zzero
        do ist = 1, wf_nwf
          auxmat( ist, :) = wf_transform( ist, :, ik)*evalin( wf_fst+ist-1, ik)
        end do
        call zgemm( 'c', 'n', wf_nwf, wf_nwf, wf_nwf, zone, &
               wf_transform( :, :, ik), wf_nwf, &
               auxmat, wf_nwf, zzero, &
               hamwk, wf_nwf)
        do ir = 1, wfint_nrpt
          hamwr( :, :, ir) = hamwr( :, :, ir) + conjg( wfint_pkr( ik, ir))/wf_kset%nkpt*hamwk
        end do
      end do

      velo = zzero
      mass = zzero
      dmat = zzero

      ! get first band-derivative (velocity)
      do d1 = 1, 3
        do iq = 1, wfint_kset%nkpt
          hamwk = zzero
          do ir = 1, wfint_nrpt
            call r3mv( input%structure%crystal%basevect, dble( wfint_rvec( :, ir)), vr)
            hamwk = hamwk + zi*vr( d1)*wfint_pqr( iq, ir)*hamwr( :, :, ir)
          end do
          call zgemm( 'n', 'n', wf_nwf, wf_nwf, wf_nwf, zone, &
                 hamwk, wf_nwf, &
                 wfint_transform( :, :, iq), wf_nwf, zzero, &
                 auxmat, wf_nwf)
          call zgemm( 'c', 'n', wf_nwf, wf_nwf, wf_nwf, zone, &
                 wfint_transform( :, :, iq), wf_nwf, &
                 auxmat, wf_nwf, zzero, &
                 velo( :, :, d1, iq), wf_nwf)
          ! handle degeneracies of first order
          sdeg = 1
          do while( (sdeg .lt. wf_nwf) .and. (d1 .eq. ddeg))
            ndeg = 1
            do while( (sdeg .lt. wf_nwf) .and. &
                (abs( wfint_eval( sdeg, iq) - wfint_eval( sdeg+1, iq)) .lt. eps1))
              ndeg = ndeg + 1
              sdeg = sdeg + 1
            end do
            if( ndeg .gt. 1) then
              allocate( degmat( ndeg, ndeg), degevec( ndeg, ndeg), degeval( ndeg))
              degmat = velo( (sdeg-ndeg+1):sdeg, (sdeg-ndeg+1):sdeg, d1, iq)
              call diaghermat( ndeg, degmat, degeval, degevec)
              call zgemm( 'n', 'n', wf_nwf, ndeg, ndeg, zone, &
                     wfint_transform( :, (sdeg-ndeg+1):sdeg, iq), wf_nwf, &
                     degevec, ndeg, zzero, &
                     auxmat( :, 1:ndeg), wf_nwf)
              wfint_transform( :, (sdeg-ndeg+1):sdeg, iq) = auxmat( :, 1:ndeg)
              call zgemm( 'n', 'n', wf_nwf, wf_nwf, wf_nwf, zone, &
                     hamwk, wf_nwf, &
                     wfint_transform( :, :, iq), wf_nwf, zzero, &
                     auxmat, wf_nwf)
              call zgemm( 'c', 'n', wf_nwf, wf_nwf, wf_nwf, zone, &
                     wfint_transform( :, :, iq), wf_nwf, &
                     auxmat, wf_nwf, zzero, &
                     velo( :, :, d1, iq), wf_nwf)
              deallocate( degmat, degevec, degeval)
            else
              sdeg = sdeg + 1
            end if
          end do
        end do

        ! set up D-matrix
        do iq = 1, wfint_kset%nkpt
          do ist = 1, wf_nwf
            do jst = 1, wf_nwf
              if( abs( wfint_eval( ist, iq) - wfint_eval( jst, iq)) .gt. eps1) then
                dmat( ist, jst, d1, iq) = velo( ist, jst, d1, iq)/(wfint_eval( jst, iq) - wfint_eval( ist, iq))
              end if
            end do
          end do
        end do
      end do

      do d1 = 1, 3
        ! get second band-derivative (inverse effective mass)
        do iq = 1, wfint_kset%nkpt
          do d2 = 1, 3
            hamwk = zzero
            do ir = 1, wfint_nrpt
              call r3mv( input%structure%crystal%basevect, dble( wfint_rvec( :, ir)), vr)
              hamwk = hamwk - vr( d1)*vr( d2)*wfint_pqr( iq, ir)*hamwr( :, :, ir)
            end do
            call zgemm( 'n', 'n', wf_nwf, wf_nwf, wf_nwf, zone, &
                   hamwk, wf_nwf, &
                   wfint_transform( :, :, iq), wf_nwf, zzero, &
                   auxmat, wf_nwf)
            call zgemm( 'c', 'n', wf_nwf, wf_nwf, wf_nwf, zone, &
                   wfint_transform( :, :, iq), wf_nwf, &
                   auxmat, wf_nwf, zzero, &
                   mass( :, :, d1, d2, iq), wf_nwf)
            call zgemm( 'n', 'n', wf_nwf, wf_nwf, wf_nwf, zone, &
                   velo( :, :, d1, iq), wf_nwf, &
                   dmat( :, :, d2, iq), wf_nwf, zzero, &
                   auxmat, wf_nwf)
            mass( :, :, d1, d2, iq) = mass( :, :, d1, d2, iq) + auxmat + conjg( transpose( auxmat))
            ! handle degeneracies of second order
            sdeg = 1
            do while( (sdeg .lt. wf_nwf) .and. (d1 .eq. ddeg) .and. (d2 .eq. ddeg))
              ndeg = 1
              do while( (sdeg .lt. wf_nwf) .and. &
                  (abs( velo( sdeg, sdeg, d1, iq) - velo( sdeg+1, sdeg+1, d1, iq)) .lt. eps2) .and. &
                  (abs( wfint_eval( sdeg, iq) - wfint_eval( sdeg+1, iq)) .lt. eps1))
                ndeg = ndeg + 1
                sdeg = sdeg + 1
              end do
              if( ndeg .gt. 1) then
                allocate( degmat( ndeg, ndeg), degevec( ndeg, ndeg), degeval( ndeg))
                degmat = mass( (sdeg-ndeg+1):sdeg, (sdeg-ndeg+1):sdeg, d1, d2, iq)
                call diaghermat( ndeg, degmat, degeval, degevec)
                do ist = 1, ndeg
                  mass( sdeg-ndeg+ist, sdeg-ndeg+ist, d1, d2, iq) = cmplx( degeval( ist), 0, 8)
                end do
                call zgemm( 'n', 'n', wf_nwf, ndeg, ndeg, zone, &
                       wfint_transform( :, (sdeg-ndeg+1):sdeg, iq), wf_nwf, &
                       degevec, ndeg, zzero, &
                       auxmat( :, 1:ndeg), wf_nwf)
                wfint_transform( :, (sdeg-ndeg+1):sdeg, iq) = auxmat( :, 1:ndeg)
                deallocate( degmat, degevec, degeval)
              else
                sdeg = sdeg + 1
              end if
            end do
          end do
        end do
      end do

      velo_ = 0.d0
      mass_ = 0.d0
      do iq = 1, wfint_kset%nkpt
        write(*,'("--------------------")')
        write(*,'(I,5x,3F13.6)') iq, wfint_kset%vkc( :, iq)
        vk = wfint_kset%vkc( :, iq+1) - wfint_kset%vkc( :, iq)
        vk = vk/norm2( vk)
        do ist = 1, wf_nwf
          velo_( :, ist, iq) = dble( velo( ist, ist, :, iq))
          !if( abs( r3mdet( dble( mass( ist, ist, :, :, iq)))) .gt. 1.d-10) then
          !  call r3minv( dble( mass( ist, ist, :, :, iq)), mass_( :, :, ist, iq))
          !end if
          mass_( :, :, ist, iq) = dble( mass( ist, ist, :, :, iq))
          write(*,'(i,3f13.6,3x,f13.6)') ist, velo_( :, ist, iq), dot_product( velo_( :, ist, iq), vk)
          write(*,'(3f13.6)') mass_( 1, :, ist, iq)
          write(*,'(3f13.6)') mass_( 2, :, ist, iq)
          write(*,'(3f13.6)') mass_( 3, :, ist, iq)
        end do
      end do

      return
    end subroutine wfint_interpolate_ederiv

!--------------------------------------------------------------------------------------
    
    subroutine wfint_find_bandgap
      use mod_eigenvalue_occupancy, only: occmax
      use mod_charge_and_moment, only: chgval

      integer :: iq, nvm, iqvbm, iqcbm, ndiv(3), degvbm, degcbm, ist
      real(8) :: vvbm(3), vcbm(3), v0(3), w(3), d(3), evbm, ecbm, eps
      type( k_set) :: tmp_kset

      real(8), allocatable :: velo(:,:,:), mass(:,:,:,:)

      eps = 1.d-4

      nvm = nint( chgval/occmax)
      if( (wf_fst .ne. 1) .and. (wf_fst .le. nvm)) then
        write( *, '(" Warning (wfint_find_bandgap): The lowest wannierized band is ",I3,". All bands below are considered to be fully occupied.")') wf_fst
      end if
      if( wf_fst .gt. nvm) then
        write( *, '(" Error (wfint_find_bandgap): No valence bands have been wannierized. Occupancies cannot be determined.")')
        call terminate
      end if
      if( (wf_lst .le. nvm)) then
        write( *, '(" Error (wfint_find_bandgap): At least one conduction band has to be wannierized in order to determine occupancies.")')
        call terminate
      end if

      nvm = nvm - wf_fst + 1

      ndiv = (/10, 10, 10/)
      w = (/1.d0, 1.d0, 1.d0/)
      d = w/ndiv

      call generate_k_vectors( tmp_kset, bvec, 3*ndiv, (/0.d0, 0.d0, 0.d0/), .true.)
      call wfint_init( tmp_kset)

      if( maxval( wfint_eval( nvm, :)) .gt. minval( wfint_eval( nvm+1, :))) then
        write( *, '(" Error (wfint_find_bandgap): I think your system is metalic. No gap can be found.")')
        call terminate
      end if

      iqvbm = maxloc( wfint_eval( nvm, :), 1)
      evbm = wfint_eval( nvm, iqvbm)
      vvbm = wfint_kset%vkl( :, iqvbm)

      iqcbm = minloc( wfint_eval( nvm+1, :), 1)
      ecbm = wfint_eval( nvm+1, iqcbm)
      vcbm = wfint_kset%vkl( :, iqcbm)

      ! find VBM
      do while( norm2( d) .gt. eps)
        w = 2.d0*d
        d = w/ndiv
        v0 = vvbm - 0.5d0*(w - d)
        call generate_k_vectors( tmp_kset, bvec, ndiv, (/0.d0, 0.d0, 0.d0/), .false.)
        do iq = 1, tmp_kset%nkpt
          tmp_kset%vkl( :, iq) = tmp_kset%vkl( :, iq)*w + v0
          call r3mv( bvec, tmp_kset%vkl( :, iq), tmp_kset%vkc( :, iq))
        end do
        call wfint_init( tmp_kset)
        iqvbm = maxloc( wfint_eval( nvm, :), 1)
        evbm = wfint_eval( nvm, iqvbm)
        vvbm = wfint_kset%vkl( :, iqvbm)
      end do
        
      ! find CBM
      w = (/1.d0, 1.d0, 1.d0/)
      d = w/ndiv
      do while( norm2( d) .gt. input%structure%epslat)
        w = 2.d0*d
        d = w/ndiv
        v0 = vcbm - 0.5d0*(w - d)
        call generate_k_vectors( tmp_kset, bvec, ndiv, (/0.d0, 0.d0, 0.d0/), .false.)
        do iq = 1, tmp_kset%nkpt
          tmp_kset%vkl( :, iq) = tmp_kset%vkl( :, iq)*w + v0
          call r3mv( bvec, tmp_kset%vkl( :, iq), tmp_kset%vkc( :, iq))
        end do
        call wfint_init( tmp_kset)
        iqcbm = minloc( wfint_eval( nvm+1, :), 1)
        ecbm = wfint_eval( nvm+1, iqvbm)
        vcbm = wfint_kset%vkl( :, iqcbm)
      end do

      call generate_k_vectors( tmp_kset, bvec, (/1, 1, 2/), (/0.d0, 0.d0, 0.d0/), .false.)
      tmp_kset%vkl( :, 1) = vvbm
      call r3mv( bvec, tmp_kset%vkl( :, 1), tmp_kset%vkc( :, 1))
      tmp_kset%vkl( :, 2) = vcbm
      call r3mv( bvec, tmp_kset%vkl( :, 2), tmp_kset%vkc( :, 2))
      call wfint_init( tmp_kset)
      allocate( velo( 3, wf_nwf, wfint_kset%nkpt))
      allocate( mass( 3, 3, wf_nwf, wfint_kset%nkpt))
      call wfint_interpolate_ederiv( velo, mass)
      degvbm = 0
      degcbm = 0
      do ist = 1, wf_nwf
        if( abs( wfint_eval( ist, 1) - wfint_eval( nvm, 1)) .lt. eps) degvbm = degvbm + 1
        if( abs( wfint_eval( ist, 2) - wfint_eval( nvm+1, 2)) .lt. eps) degcbm = degcbm + 1
      end do

      write(*,*) "VALENCE-BAND MAXIMUM"
      write(*,'(" position (lattice):   ",3f13.6)') wfint_kset%vkl( :, 1)
      write(*,'("          (cartesian): ",3f13.6)') wfint_kset%vkc( :, 1)
      write(*,'(" energy (Hartree):     ",f13.6)') wfint_eval( nvm, 1)
      write(*,'("        (eV):          ",f13.6)') wfint_eval( nvm, 1)*27.211396641308
      write(*,'(" degeneracy:           ",i6)') degvbm
      write(*,'(" band-gradient:        ",3f13.6)') velo( :, nvm, 1)
      write(*,'(" effecitve mass tensor:",3f13.6)') mass( 1, :, nvm, 1)
      write(*,'("                       ",3f13.6)') mass( 2, :, nvm, 1)
      write(*,'("                       ",3f13.6)') mass( 3, :, nvm, 1)
      write(*,*)

      write(*,*) "CONDUCTION-BAND MINIMUM"
      write(*,'(" position (lattice):   ",3f13.6)') wfint_kset%vkl( :, 2)
      write(*,'("          (cartesian): ",3f13.6)') wfint_kset%vkc( :, 2)
      write(*,'(" energy (Hartree):     ",f13.6)') wfint_eval( nvm+1, 2)
      write(*,'("        (eV):          ",f13.6)') wfint_eval( nvm+1, 2)*27.211396641308
      write(*,'(" degeneracy:           ",i6)') degcbm
      write(*,'(" band-gradient:        ",3f13.6)') velo( :, nvm+1, 2)
      write(*,'(" effecitve mass tensor:",3f13.6)') mass( 1, :, nvm+1, 2)
      write(*,'("                       ",3f13.6)') mass( 2, :, nvm+1, 2)
      write(*,'("                       ",3f13.6)') mass( 3, :, nvm+1, 2)
      write(*,*)

      write(*,'(" gap (Hartree):        ",f13.6)') wfint_eval( nvm+1, 2) - wfint_eval( nvm, 1)
      write(*,'("     (eV):             ",f13.6)') (wfint_eval( nvm+1, 2) - wfint_eval( nvm, 1))*27.211396641308
      return
    end subroutine wfint_find_bandgap

!--------------------------------------------------------------------------------------
    
    !BOP
    ! !ROUTINE: wfint_interpolate_occupancy
    ! !INTERFACE:
    !
    subroutine wfint_interpolate_density( lmax, rhomt_int, rhoir_int)
      ! !USES:
      use mod_SHT
      ! !DESCRIPTION:
      !   Calclulates the interpolated occupation numbers for the wannierized bands and
      !   interpolated Fermi energy.
      !
      ! !REVISION HISTORY:
      !   Created July 2017 (SeTi)
      !EOP
      !BOC

      integer, intent( in) :: lmax
      real(8), intent( out) :: rhomt_int( (lmax+1)**2, nrmtmax, natmtot)
      real(8), intent( out) :: rhoir_int( ngrtot)

      integer :: ik, iq, ir, o, ilo1, l1, m1, lm1, lm2, lmmax, lam, lammax, maxdim, ist, ia, is, ias, ig, igk
      integer :: lamcnt( 0:lmax, nspecies), o2idx( apwordmax, 0:lmax, nspecies), lo2idx( nlomax, 0:lmax, nspecies)
      character(256) :: fname

      real(8), allocatable :: radfun(:,:,:,:), rhopart(:,:)
      complex(8), allocatable :: radcoeffr(:,:,:,:,:), radcoeffq(:,:,:), frad(:,:), auxmat(:,:), auxmat2(:,:)
      complex(8), allocatable :: psik(:,:), psiq(:,:,:), evecfv(:,:,:)

      lmmax = (lmax + 1)**2

      !--------------------------------------!
      !              muffin-tin              !
      !--------------------------------------!
      !===========================================
      ! real space radial expansion coefficients
      !===========================================
      call wfint_gen_radcoeffr( lmax, lammax, radcoeffr)

      !===========================================
      ! get radial functions
      !===========================================
      call wannier_genradfun

      maxdim = 0
      allocate( radfun( lammax, 0:lmax, natmtot, nrmtmax))
      radfun(:,:,:,:) = 0.d0
      do is = 1, nspecies
        o2idx( :, :, is) = 0
        lo2idx( :, :, is) = 0
        lamcnt( :, is) = 0
        do l1 = 0, lmax
          do o = 1, apword( l1, is)
            lamcnt( l1, is) = lamcnt( l1, is) + 1
            o2idx( o, l1, is) = lamcnt( l1, is)
            do ia = 1, natoms( is)
              ias = idxas( ia, is)
              radfun( o2idx( o, l1, is), l1, ias, :) = apwfr( :, 1, o, l1, ias)
            end do
          end do
        end do
        do ilo1 = 1, nlorb( is)
          l1 = lorbl( ilo1, is)
          if( l1 .le. lmax) then
            lamcnt( l1, is) = lamcnt( l1, is) + 1
            lo2idx( ilo1, l1, is) = lamcnt( l1, is)
            do ia = 1, natoms( is)
              ias = idxas( ia, is)
              radfun( lo2idx( ilo1, l1, is), l1, ias, :) = lofr( :, 1, ilo1, ias)
            end do
          end if
        end do
        maxdim = max( maxdim, maxval( lamcnt( :, is)))
      end do

      if( lammax .ne. maxdim) then
        write(*,'("Error (wfint_interpolate_density): Oops! Something went wrong.")')
        call terminate
      end if

      !===========================================
      ! interpolate occupancies
      !===========================================
      call wfint_interpolate_occupancy

      !===========================================
      ! density
      !===========================================
      allocate( radcoeffq( lammax, wf_nwf, lmmax))
      allocate( frad( lmmax, nrmtmax))
      allocate( rhopart( lmmax, nrmtmax))
      allocate( auxmat( lmmax, nrmtmax))
      allocate( auxmat2( wf_nwf, lammax))

      rhomt_int = 0.d0
      do iq = 1, wfint_kset%nkpt
        do is = 1, nspecies
          do ia = 1, natoms( is)
            ias = idxas( ia, is)

            radcoeffq = zzero
            do l1 = 0, lmax
              do m1 = -l1, l1
                lm1 = idxlm( l1, m1)
                ! reciprocal space radial expansion coefficient
                auxmat2 = zzero
                do ir = 1, wf_kset%nkpt
                  auxmat2 = auxmat2 + wfint_pqr( iq, ir)*radcoeffr( :, :, lm1, ias, ir)
                end do
                call zgemm( 't', 'n', lammax, wf_nwf, wf_nwf, zone, &
                     auxmat2, wf_nwf, &
                     wfint_transform( :, :, iq), wf_nwf, zzero, &
                     radcoeffq( :, :, lm1), lammax)
              end do
            end do

            do ist = 1, wf_nwf
              if( wfint_occ( ist, iq) .gt. input%groundstate%epsocc) then
                ! build radial function
                frad = zzero
                do l1 = 0, lmax
                  do m1 = -l1, l1
                    lm1 = idxlm( l1, m1)
                    do lam = 1, lamcnt( l1, is)
                      frad( lm1, :) = frad( lm1, :) + radcoeffq( lam, ist, lm1)*radfun( lam, l1, ias, :)
                    end do
                  end do
                end do
                ! convert from spherical harmonics to spherical coordinates
                call zgemm( 'n', 'n', lmmax, nrmt( is), lmmax, 1.d0, &
                     zbshtvr, lmmaxvr, &
                     frad, lmmax, 0.d0, &
                     auxmat, lmmax)
                ! take square modulus
                rhopart = dble( auxmat)**2 + dble( aimag( auxmat))**2
                ! convert back to spherical harmonics and add to muffin-tin density
                call dgemm( 'n', 'n', lmmax, nrmt( is), lmmax, wfint_kset%wkpt( iq)*wfint_occ( ist, iq), &
                     rfshtvr, lmmaxvr, &
                     rhopart, lmmax, 1.d0, &
                     rhomt_int( :, :, ias), lmmax)
              end if
            end do

          end do
        end do
      end do

      deallocate( radcoeffr, radcoeffq, frad, radfun, auxmat, rhopart)

      !--------------------------------------!
      !             interstitial             !
      !--------------------------------------!

      allocate( evecfv( nmatmax, nstfv, nspnfv))
      allocate( psik( ngrtot, wf_nwf))
      allocate( psiq( ngrtot, wf_nwf, wfint_kset%nkpt))
      allocate( auxmat( ngrtot, wf_nwf))

      psiq = zzero
      do ik = 1, wf_kset%nkpt
        ! read eigenvector      
        call wannier_getevec( ik, evecfv)

        auxmat = zzero
!#ifdef USEOMP
!!$omp parallel default( shared) private( ist, igk)
!!$omp do
!#endif
        do ist = 1, wf_nwf
          do igk = 1, wf_Gkset%ngk( 1, ik)
            auxmat( igfft( wf_Gkset%igkig( igk, 1, ik)), ist) = evecfv( igk, wf_fst+ist-1, 1)
          end do
        end do
!#ifdef USEOMP
!!$omp end do
!!$omp end parallel
!#endif
        
        call zgemm( 'n', 'n', ngrtot, wf_nwf, wf_nwf, zone, &
             auxmat, ngrtot, &
             wf_transform( :, :, ik), wf_nwf, zzero, &
             psik, ngrtot)
#ifdef USEOMP
!$omp parallel default( shared) private( iq)
!$omp do
#endif
        do iq = 1, wfint_kset%nkpt
          call zgemm( 'n', 'n', ngrtot, wf_nwf, wf_nwf, cmplx( wfint_phase( ik, iq), 0, 8), &
               psik, ngrtot, &
               wfint_transform( :, :, iq), wf_nwf, zone, &
               psiq( :, :, iq), ngrtot)
        end do
#ifdef USEOMP
!$omp end do
!$omp end parallel
#endif
      end do
      deallocate( evecfv, psik)

      rhoir_int = zzero
#ifdef USEOMP
!!$omp parallel default( shared) private( iq, ist, igk)
!!$omp do collapse(2)
#endif
      do iq = 1, wfint_kset%nkpt
        do ist = 1, wf_nwf
          if( wfint_occ( ist, iq) .gt. input%groundstate%epsocc) then
            call zfftifc( 3, ngrid, 1, psiq( :, ist, iq))
            do igk = 1, ngrtot
              rhoir_int( igk) = rhoir_int( igk) + wfint_occ( ist, iq)*wfint_kset%wkpt( iq)/omega*&
                (dble( psiq( igk, ist, iq))**2 + dble( aimag( psiq( igk, ist, iq)))**2)
            end do
          end if
        end do
      end do
#ifdef USEOMP
!!$omp end do
!!$omp end parallel
#endif

      call symrf( input%groundstate%lradstep, rhomt, rhoir)
      call rfmtctof( rhomt)
      !call gencore
      !call addrhocr

      call charge

      write(*,'(100F13.6)') chgmt
      write(*,'(F13.6)') chgir
      write(*,'(F13.6)') chgcalc
      write(*,'(F13.6)') chgtot
      write(*,*)

      rhomt = rhomt_int
      rhoir = rhoir_int
      call rfmtctof( rhomt)
      call gencore
      call addrhocr

      call charge

      write(*,'(100F13.6)') chgmt
      write(*,'(F13.6)') chgir
      write(*,'(F13.6)') chgcalc
      write(*,'(F13.6)') chgtot
      write(*,*)

      call symrf( input%groundstate%lradstep, rhomt, rhoir)
      call rfmtctof( rhomt)
      !call gencore
      !call addrhocr

      call charge

      write(*,'(100F13.6)') chgmt
      write(*,'(F13.6)') chgir
      write(*,'(F13.6)') chgcalc
      write(*,'(F13.6)') chgtot
      write(*,*)

      call rhonorm
      call charge

      write(*,'(100F13.6)') chgmt
      write(*,'(F13.6)') chgir
      write(*,'(F13.6)') chgcalc
      write(*,'(F13.6)') chgtot
      write(*,*)
      write(*,*)
      
      call writestate
    end subroutine wfint_interpolate_density
    !EOC

!--------------------------------------------------------------------------------------
      
    subroutine wfint_interpolate_bandchar( lmax, bc)
      integer, intent( in) :: lmax
      real(8), intent( out) :: bc( 0:lmax, natmtot, wf_nwf, wfint_kset%nkpt)

      integer :: iq, l, m, lm, lmmax, lammax, ist, ias
      real(8), allocatable :: radolp(:,:,:,:), elm(:,:)
      complex(8), allocatable :: dmat(:,:,:,:), radcoeffr(:,:,:,:,:), ulm(:,:,:), auxmat(:,:)

      lmmax = (lmax + 1)**2

      call wfint_gen_radcoeffr( lmax, lammax, radcoeffr)
      call wfint_gen_radolp( lmax, lammax, radolp)

      allocate( elm( lmmax, natmtot))
      allocate( ulm( lmmax, lmmax, natmtot))
      call genlmirep( lmax, lmmax, elm, ulm)

      bc = 0.d0
#ifdef USEOMP
!$omp parallel default( shared) private( iq, dmat, auxmat, l, m, lm, ist, ias)
#endif
      allocate( dmat( lmmax, lmmax, wf_nwf, natmtot))
      allocate( auxmat( lmmax, lmmax))
#ifdef USEOMP
!$omp do
#endif
      do iq = 1, wfint_kset%nkpt
        call wfint_interpolate_dmat( lmax, lammax, iq, radcoeffr, radolp, dmat, diagonly=.false.)
        do ias = 1, natmtot
          do ist = 1, wf_nwf
            call zgemm( 'n', 'n', lmmax, lmmax, lmmax, zone, &
                 ulm( :, :, ias), lmmax, &
                 dmat( :, :, ist, ias), lmmax, zzero, &
                 auxmat, lmmax)
            call zgemm( 'n', 'c', lmmax, lmmax, lmmax, zone, &
                 auxmat, lmmax, &
                 ulm( :, :, ias), lmmax, zzero, &
                 dmat( :, :, ist, ias), lmmax)
            do l = 0, lmax
              do m = -l, l
                lm = idxlm( l, m)
#ifdef USEOMP
!$omp atomic update
#endif
                bc( l, ias, ist, iq) = bc( l, ias, ist, iq) + dble( dmat( lm, lm, ist, ias))
#ifdef USEOMP
!$omp end atomic
#endif
              end do
            end do
          end do
        end do
      end do
#ifdef USEOMP
!$omp end do
#endif
      deallocate( dmat, auxmat)
#ifdef USEOMP
!$omp end parallel
#endif

      if( allocated( radcoeffr)) deallocate( radcoeffr)
      if( allocated( radolp)) deallocate( radolp)

      return
      
    end subroutine wfint_interpolate_bandchar

    subroutine wfint_interpolate_bandchar_new( lmax, bc)
      integer, intent( in) :: lmax
      real(8), intent( out) :: bc( 0:lmax, natmtot, wf_nwf, wfint_kset%nkpt)

      integer :: iq, is, ia, ias, ist, l, m, lm, lmmax, ngkmax_, nmatmax_

      complex(8), allocatable :: dmat(:,:,:,:,:), apwalm(:,:,:,:,:), evecfv(:,:,:), evecsv(:,:)

      lmmax = (lmax + 1)**2
      ngkmax_ = ngkmax
      nmatmax_ = nmatmax

      call wfint_interpolate_eigvec

      ngkmax = wfint_Gkset%ngkmax
      nmatmax = ngkmax + nlotot

      allocate( dmat( lmmax, lmmax, nspinor, nspinor, nstsv))
      allocate( apwalm( ngkmax, apwordmax, lmmaxapw, natmtot, nspnfv))
      allocate( evecfv( nmatmax, nstfv, nspnfv))
      allocate( evecsv( nstsv, nstsv))
      evecsv = zzero
      
      bc = 0.d0
      do iq = 1, wfint_kset%nkpt
        call match( wfint_Gkset%ngk( 1, iq), wfint_Gkset%gkc( :, 1, iq), wfint_Gkset%tpgkc( :, :, 1, iq), wfint_Gkset%sfacgk( :, :, 1, iq), apwalm( :, :, :, :, 1))
        evecfv = zzero
        evecfv( :, 1:wf_nwf, 1) = wfint_evec( :, :, iq)
        do is = 1, nspecies
          do ia = 1, natoms( is)
            ias = idxas( ia, is)
            call gendmat( .true., .true., 0, lmax, is, ia, wfint_Gkset%ngk( 1, iq), apwalm, evecfv, evecsv, lmmax, dmat)
            do ist = 1, wf_nwf
              do l = 0, lmax
                do m = -l, l
                  lm = idxlm( l, m)
                  bc( l, ias, ist, iq) = bc( l, ias, ist, iq) + dble( dmat( lm, lm, 1, 1, ist))
                end do
              end do
            end do
          end do
        end do
      end do

      return
    end subroutine wfint_interpolate_bandchar_new

!--------------------------------------------------------------------------------------

subroutine wfint_interpolate_dos( lmax, nsmooth, intgrid, neffk, nsube, ewin, tdos, scissor, pdos, jdos, mtrans, ntrans)
      use mod_eigenvalue_occupancy, only: occmax

      integer, intent( in) :: lmax, nsmooth, intgrid(3), neffk, nsube
      real(8), intent( in) :: ewin(2)
      real(8), intent( out) :: tdos( nsube)
      ! optional arguments
      real(8), optional, intent( in) :: scissor
      real(8), optional, intent( out) :: pdos( nsube, (lmax+1)**2, natmtot)
      real(8), optional, intent( out) :: jdos( nsube, 0:wf_nwf)
      integer, optional, intent( out) :: mtrans, ntrans

      integer :: lmmax, is, ia, ias, l, m, lm, ist, jst, iq, ie, nk(3), lammax, n
      real(8) :: de, chg, stheta, t1, dosscissor
      type( k_set) :: tmp_kset
      character(256) :: fname
      logical :: genpdos, genjdos

      real(8), allocatable :: energies(:,:), radolp(:,:,:,:), elm(:,:), e(:), ftdos(:,:), fjdos(:,:), fpdos(:,:,:,:), edif(:,:,:), ejdos(:,:)
      complex(8), allocatable :: ulm(:,:,:), radcoeffr(:,:,:,:,:), dmat(:,:,:,:), auxmat(:,:)

      real(8) :: rhomt_int(lmmaxvr, nrmtmax, natmtot), rhoir_int( ngrtot)

      dosscissor = 0.d0
      if( present( scissor)) dosscissor = scissor

      genpdos = .false.
      if( present( pdos)) genpdos = .true.

      genjdos = .false.
      if( present( jdos)) genjdos = .true.
      if( genjdos .and. (.not. present( mtrans) .or. .not. present( ntrans))) then
        write(*,*) "Error (wfint_interpolate_dos): Joint DOS requested but missing arguments for number of transitions."
        call terminate
      end if

      lmmax = (lmax+1)**2

      write(*,*) "dos: set up interpolation grid"
      write(*,'(" dos: ngridk = "3I4)') intgrid
      call generate_k_vectors( tmp_kset, bvec, intgrid, wf_kset%vkloff, .true., uselibzint=.false.)
      nk(:) = max( neffk/tmp_kset%ngridk, 1)
      write(*,'(" dos: nkpt   = "I)') tmp_kset%nkpt
      write(*,'(" dos: nk     = "3I4)') nk
      write(*,*) "dos: interpolate energies"
      call wfint_init( tmp_kset)

      !call wfint_interpolate_density( input%groundstate%lmaxvr, rhomt_int, rhoir_int)
      !call wfint_interpolate_gwpermat
      !stop

      write(*,*) "dos: interpolate occupancy"
      call wfint_interpolate_occupancy
      write(*,'(F23.16)') wfint_efermi
      allocate( energies( wf_nwf, wfint_kset%nkpt))
      energies = wfint_eval - wfint_efermi

      allocate( elm( lmmax, natmtot))
      allocate( ulm( lmmax, lmmax, natmtot))
      allocate( ftdos( wf_nwf, wfint_kset%nkpt))
      allocate( fpdos( wf_nwf, wfint_kset%nkpt, lmmax, natmtot))
      allocate( e( nsube))

      call genlmirep( lmax, lmmax, elm, ulm)

      do ie = 1, nsube
        e( ie) = ewin(1) + (ie-0.5d0)*(ewin(2)-ewin(1))/nsube
      end do

      !--------------------------------------!
      !              total DOS               !
      !--------------------------------------!
      write(*,*) "dos: calculate total dos"
      do iq = 1, wfint_kset%nkpt
        ftdos( :, iq) = 1.d0
        do ist = 1, wf_nwf
          if( energies( ist, iq) .gt. 0.d0) energies( ist, iq) = energies( ist, iq) + dosscissor
        end do
      end do

      call brzint( nsmooth, wfint_kset%ngridk, nk, wfint_kset%ikmap, nsube, ewin, wf_nwf, wf_nwf, &
           energies, &
           ftdos, &
           tdos)

      !--------------------------------------!
      !             partial DOS              !
      !--------------------------------------!
      if( genpdos) then
        fpdos(:,:,:,:) = 0.d0
        write(*,*) "dos: generate radcoeffr"
        call wfint_gen_radcoeffr( lmax, lammax, radcoeffr)
        call wfint_gen_radolp( lmax, lammax, radolp)

        write(*,*) "dos: interpolate dmat"
#ifdef USEOMP
!$omp parallel default( shared) private( iq, dmat, ias, ist, auxmat, lm)
#endif
        allocate( dmat( lmmax, lmmax, wf_nwf, natmtot))
        allocate( auxmat( lmmax, lmmax))
#ifdef USEOMP
!$omp do
#endif
        do iq = 1, wfint_kset%nkpt
          call wfint_interpolate_dmat( lmax, lammax, iq, radcoeffr, radolp, dmat)
          do ias = 1, natmtot
            do ist = 1, wf_nwf
              call zgemm( 'n', 'n', lmmax, lmmax, lmmax, zone, &
                   ulm( :, :, ias), lmmax, &
                   dmat( :, :, ist, ias), lmmax, zzero, &
                   auxmat, lmmax)
              call zgemm( 'n', 'c', lmmax, lmmax, lmmax, zone, &
                   auxmat, lmmax, &
                   ulm( :, :, ias), lmmax, zzero, &
                   dmat( :, :, ist, ias), lmmax)
              do lm = 1, lmmax
#ifdef USEOMP
!$omp atomic write
#endif
                fpdos( ist, iq, lm, ias) = dble( dmat( lm, lm, ist, ias))
#ifdef USEOMP
!$omp end atomic
#endif
              end do
            end do
          end do
        end do
#ifdef USEOMP
!$omp end do
#endif
        deallocate( dmat, auxmat)
#ifdef USEOMP
!$omp end parallel
#endif

        write(*,*) "dos: calculate partial dos"
#ifdef USEOMP
!$omp parallel default( shared) private( ias, lm)
!$omp do collapse( 2)
#endif
        do ias = 1, natmtot
          do lm = 1, lmmax
            write(*,*) ias, lm
            call brzint( nsmooth, wfint_kset%ngridk, nk, wfint_kset%ikmap, nsube, ewin, wf_nwf, wf_nwf, &
                 energies, &
                 fpdos( :, :, lm, ias), &
                 pdos( :, lm, ias))
          end do
        end do
#ifdef USEOMP
!$omp end do
!$omp end parallel
#endif
      end if

      !--------------------------------------!
      !              joint DOS               !
      !--------------------------------------!
      if( genjdos) then
        allocate( edif( wf_nwf, wfint_kset%nkpt, wf_nwf))
        edif(:,:,:) = 0.d0
        do iq = 1, wfint_kset%nkpt
          n = 0
          do ist = wf_nwf, 1, -1
            if( energies( ist, iq) .le. 0.d0) then
              n = n + 1
              m = 0
              do jst = 1, wf_nwf
                if( energies( jst, iq) .gt. 0.d0) then
                  m = m + 1
                  edif( m, iq, n) = energies( jst, iq) - energies( ist, iq)
                end if
              end do
            end if
          end do
        end do
        mtrans = m
        ntrans = n
        ! state dependent JDOS
        allocate( fjdos( m*n, wfint_kset%nkpt))
        allocate( ejdos( m*n, wfint_kset%nkpt))
        fjdos(:,:) = 1.d0
#ifdef USEOMP
!$omp parallel default( shared) private( ist)
!$omp do
#endif
        do ist = 1, n
          call brzint( nsmooth, wfint_kset%ngridk, nk, wfint_kset%ikmap, nsube, ewin, m, m, &
               edif( 1:m, :, ist), &
               fjdos( 1:m, :), &
               jdos( :, ist))
        end do
#ifdef USEOMP
!$omp end do
!$omp end parallel
#endif
        ! total JDOS
        iq = 0
        do ist = 1, n
          do jst = 1, m
            iq = iq + 1
            ejdos( iq, :) = edif( jst, :, ist)
          end do
        end do
        call brzint( nsmooth, wfint_kset%ngridk, nk, wfint_kset%ikmap, nsube, ewin, m*n, m*n, &
             ejdos, &
             fjdos, &
             jdos( :, 0))
        deallocate( edif, fjdos, ejdos)            
      end if

      write(*,*) "dos: deallocate"
      deallocate( elm, ulm, e, ftdos, fpdos, energies)
      if( allocated( radcoeffr)) deallocate( radcoeffr)
      if( allocated( radolp)) deallocate( radolp)
      write(*,*) "dos: done"

      return
      
    end subroutine wfint_interpolate_dos

!--------------------------------------------------------------------------------------
      
    subroutine wfint_interpolate_dmat( lmax, lammax, iq, radcoeffr, radolp, dmat, diagonly)
      integer, intent( in) :: lmax, lammax, iq
      complex(8), intent( in) :: radcoeffr( wf_nwf, lammax, (lmax+1)**2, natmtot, wf_kset%nkpt)
      real(8), intent( in) :: radolp( lammax, lammax, 0:lmax, natmtot)
      complex(8), intent( out) :: dmat( (lmax+1)**2, (lmax+1)**2, wf_nwf, natmtot)
      logical, optional, intent( in) :: diagonly

      integer :: ik, ir, is, ia, ias, o, l1, m1, lm1, m2, lm2, lmmax, ilo1, ilo2, maxdim, ist
      integer :: lamcnt( 0:lmax, nspecies), o2idx( apwordmax, 0:lmax, nspecies), lo2idx( nlomax, 0:lmax, nspecies)

      complex(8), allocatable :: radcoeffq1(:,:), radcoeffq2(:,:), auxmat(:,:)
      logical :: diag

      complex(8) :: zdotc

      diag = .false.
      if( present( diagonly)) diag = diagonly

      maxdim = 0
      do is = 1, nspecies
        o2idx( :, :, is) = 0
        lo2idx( :, :, is) = 0
        lamcnt( :, is) = 0
        do l1 = 0, lmax
          do o = 1, apword( l1, is)
            lamcnt( l1, is) = lamcnt( l1, is) + 1
            o2idx( o, l1, is) = lamcnt( l1, is)
          end do
        end do
        do ilo1 = 1, nlorb( is)
          l1 = lorbl( ilo1, is)
          if( l1 .le. lmax) then
            lamcnt( l1, is) = lamcnt( l1, is) + 1
            lo2idx( ilo1, l1, is) = lamcnt( l1, is)
          end if
        end do
        maxdim = max( maxdim, maxval( lamcnt( :, is)))
      end do
      if( maxdim .ne. lammax) then
        write( *, '(" Error (wfint_interpolate_dmat): Inconsistent input. Check lmax and lammax.")')
        call terminate
      end if

      ! build q-point density coefficients
      allocate( radcoeffq1( maxdim, wf_nwf))
      allocate( radcoeffq2( maxdim, wf_nwf))
      allocate( auxmat( maxdim, wf_nwf))
      dmat = zzero
      do is = 1, nspecies
        do ia = 1, natoms( is)

          do l1 = 0, lmax
            do m1 = -l1, l1
              ias = idxas( ia, is)
              lm1 = idxlm( l1, m1)
              radcoeffq1 = zzero
              do ir = 1, wf_kset%nkpt
                call zgemm( 't', 'n', maxdim, wf_nwf, wf_nwf, wfint_pqr( iq, ir), &
                     radcoeffr( :, :, lm1, ias, ir), wf_nwf, &
                     wfint_transform( :, :, iq), wf_nwf, zone, &
                     radcoeffq1, maxdim)
              end do
              if( diag) then
                call zgemm( 't', 'n', maxdim, wf_nwf, maxdim, zone, &
                     cmplx( radolp( :, :, l1, ias), 0, 8), maxdim, &
                     radcoeffq1, maxdim, zzero, &
                     auxmat, maxdim)
                do ist = 1, wf_nwf
                  dmat( lm1, lm1, ist, ias) = zdotc( lamcnt( l1, is), radcoeffq1( :, ist), 1, auxmat( :, ist), 1) 
                end do
              else
                do m2 = -l1, l1
                  lm2 = idxlm( l1, m2)
                  ! calculate q-point density coefficient
                  radcoeffq2 = zzero
                  do ir = 1, wf_kset%nkpt
                    call zgemm( 't', 'n', maxdim, wf_nwf, wf_nwf, wfint_pqr( iq, ir), &
                         radcoeffr( :, :, lm2, ias, ir), wf_nwf, &
                         wfint_transform( :, :, iq), wf_nwf, zone, &
                         radcoeffq2, maxdim)
                  end do
                  call zgemm( 't', 'n', maxdim, wf_nwf, maxdim, zone, &
                       cmplx( radolp( :, :, l1, ias), 0, 8), maxdim, &
                       radcoeffq1, maxdim, zzero, &
                       auxmat, maxdim)
                  do ist = 1, wf_nwf
                    dmat( lm1, lm2, ist, ias) = zdotc( lamcnt( l1, is), radcoeffq2( :, ist), 1, auxmat( :, ist), 1) 
                  end do
                end do
              end if
            end do
          end do

        end do
      end do

      deallocate( radcoeffq1, radcoeffq2, auxmat)
      return
      
    end subroutine wfint_interpolate_dmat

!--------------------------------------------------------------------------------------
      
    subroutine wfint_gen_radolp( lmax, lammax, radolp)
      integer, intent( in) :: lmax
      integer, intent( out) :: lammax
      real(8), allocatable, intent( out) :: radolp(:,:,:,:)

      integer :: ik, ir, is, ia, ias, o, l1, lmmax, ilo1, ilo2, maxdim
      integer :: lamcnt( 0:lmax, nspecies), o2idx( apwordmax, 0:lmax, nspecies), lo2idx( nlomax, 0:lmax, nspecies)
      character(256) :: fname

      lmmax = (lmax + 1)**2

      call wannier_genradfun

      maxdim = 0
      do is = 1, nspecies
        o2idx( :, :, is) = 0
        lo2idx( :, :, is) = 0
        lamcnt( :, is) = 0
        do l1 = 0, lmax
          do o = 1, apword( l1, is)
            lamcnt( l1, is) = lamcnt( l1, is) + 1
            o2idx( o, l1, is) = lamcnt( l1, is)
          end do
        end do
        do ilo1 = 1, nlorb( is)
          l1 = lorbl( ilo1, is)
          if( l1 .le. lmax) then
            lamcnt( l1, is) = lamcnt( l1, is) + 1
            lo2idx( ilo1, l1, is) = lamcnt( l1, is)
          end if
        end do
        maxdim = max( maxdim, maxval( lamcnt( :, is)))
      end do
      lammax = maxdim

      ! radial overlap-intergrals
      if( allocated( radolp)) deallocate( radolp)
      allocate( radolp( maxdim, maxdim, 0:lmax, natmtot))
      radolp(:,:,:,:) = 0.d0
      do is = 1, nspecies
        do ia = 1, natoms( is)
          ias = idxas( ia, is)
          ! APW-APW integral
          do l1 = 0, lmax
            do o = 1, apword( l1, is)
              radolp( o2idx( o, l1, is), o2idx( o, l1, is), l1, ias) = 1.d0
            end do
          end do
          do ilo1 = 1, nlorb( is)
            l1 = lorbl( ilo1, is)
            if( l1 .le. lmax) then
              do o = 1, apword( l1, is)
                if( (o2idx( o, l1, is) .gt. 0) .and. (lo2idx( ilo1, l1, is) .gt. 0)) then
                  radolp( o2idx( o, l1, is), lo2idx( ilo1, l1, is), l1, ias) = oalo( o, ilo1, ias)
                  radolp( lo2idx( ilo1, l1, is), o2idx( o, l1, is), l1, ias) = oalo( o, ilo1, ias)
                end if
              end do
              do ilo2 = 1, nlorb( is)
                if( lorbl( ilo2, is) .eq. l1) then
                  if( (lo2idx( ilo1, l1, is) .gt. 0) .and. (lo2idx( ilo2, l1, is) .gt. 0)) then
                    radolp( lo2idx( ilo1, l1, is), lo2idx( ilo2, l1, is), l1, ias) = ololo( ilo1, ilo2, ias)
                    radolp( lo2idx( ilo2, l1, is), lo2idx( ilo1, l1, is), l1, ias) = ololo( ilo2, ilo1, ias)
                  end if
                end if
              end do
            end if
          end do
        end do
      end do
   
      return
      
    end subroutine wfint_gen_radolp

!--------------------------------------------------------------------------------------
      
    subroutine wfint_gen_radcoeffr( lmax, lammax, radcoeffr)
      integer, intent( in) :: lmax
      integer, intent( out) :: lammax
      complex(8), allocatable, intent( out) :: radcoeffr(:,:,:,:,:)

      integer :: ik, iq, ir, is, ia, ias, l1, m1, lm1, o, ilo1, lmmax, ngknr, maxdim, ist
      integer :: lamcnt( 0:lmax, nspecies), o2idx( apwordmax, 0:lmax, nspecies), lo2idx( nlomax, 0:lmax, nspecies)
      character(256) :: fname

      complex(8), allocatable :: evecfv(:,:,:), apwalm(:,:,:,:,:), radcoeffk(:,:,:,:,:)

      lmmax = (lmax + 1)**2

      call wannier_genradfun

      maxdim = 0
      do is = 1, nspecies
        o2idx( :, :, is) = 0
        lo2idx( :, :, is) = 0
        lamcnt( :, is) = 0
        do l1 = 0, lmax
          do o = 1, apword( l1, is)
            lamcnt( l1, is) = lamcnt( l1, is) + 1
            o2idx( o, l1, is) = lamcnt( l1, is)
          end do
        end do
        do ilo1 = 1, nlorb( is)
          l1 = lorbl( ilo1, is)
          if( l1 .le. lmax) then
            lamcnt( l1, is) = lamcnt( l1, is) + 1
            lo2idx( ilo1, l1, is) = lamcnt( l1, is)
          end if 
        end do
        maxdim = max( maxdim, maxval( lamcnt( :, is)))
      end do
      lammax = maxdim
   
      ! build k-point density coefficients
      allocate( radcoeffk( wf_nwf, maxdim, lmmax, natmtot, wf_kset%nkpt))
      allocate( evecfv( nmatmax, nstfv, nspnfv))
      allocate( apwalm( ngkmax, apwordmax, lmmaxapw, natmtot, nspnfv))
      radcoeffk(:,:,:,:,:) = zzero

      do ik = 1, wf_kset%nkpt
        ngknr = wf_Gkset%ngk( 1, ik)

        ! get matching coefficients
        call match( ngknr, wf_Gkset%gkc( :, 1, ik), wf_Gkset%tpgkc( :, :, 1, ik), wf_Gkset%sfacgk( :, :, 1, ik), apwalm( :, :, :, :, 1))
          
        ! read eigenvector      
        call wannier_getevec( ik, evecfv)

        do is = 1, nspecies
          do ia = 1, natoms( is)
            ias = idxas( ia, is)
            ! APW contribution
            do l1 = 0, lmax
              do m1 = -l1, l1
                lm1 = idxlm( l1, m1)
                do o = 1, apword( l1, is)
                  call zgemv( 'T', ngknr, wf_nwf, zone, &
                       evecfv( :, wf_fst:(wf_fst+wf_nwf-1), 1), nmatmax, &
                       apwalm( :, o, lm1, ias, 1), 1, zzero, &
                       radcoeffk( :, o2idx( o, l1, is), lm1, ias, ik), 1)
                end do
              end do
            end do
            ! LO contribution
            do ilo1 = 1, nlorb( is)
              l1 = lorbl( ilo1, is)
              if( l1 .le. lmax) then
                do m1 = -l1, l1
                  lm1 = idxlm( l1, m1)
                  radcoeffk( :, lo2idx( ilo1, l1, is), lm1, ias, ik) = evecfv( ngknr+idxlo( lm1, ilo1, ias), wf_fst:(wf_fst+wf_nwf-1), 1)
                end do
              end if
            end do
          end do
        end do
      end do

      deallocate( evecfv, apwalm)

      ! build R-point density coefficients
      if( allocated( radcoeffr)) deallocate( radcoeffr)
      allocate( radcoeffr( wf_nwf, maxdim, lmmax, natmtot, wfint_nrpt))
      radcoeffr(:,:,:,:,:) = zzero
#ifdef USEOMP                
!$omp parallel default( shared) private( ir, ik, is, ia, ias, lm1)
!$omp do
#endif
      do ir = 1, wfint_nrpt
        do ik = 1, wf_kset%nkpt
          do is = 1, nspecies
            do ia = 1, natoms( is)
              ias = idxas( ia, is)
              do lm1 = 1, lmmax
                call zgemm( 't', 'n', wf_nwf, maxdim, wf_nwf, conjg( wfint_pkr( ik, ir))/wf_kset%nkpt, &
                       wf_transform( :, :, ik), wf_nwf, &
                       radcoeffk( :, :, lm1, ias, ik), wf_nwf, zone, &
                       radcoeffr( :, :, lm1, ias, ir), wf_nwf)
              end do
            end do
          end do
        end do
      end do
#ifdef USEOMP                
!$omp end do
!$omp end parallel
#endif
      
      deallocate( radcoeffk)

      return
      
    end subroutine wfint_gen_radcoeffr

!--------------------------------------------------------------------------------------

    subroutine wfint_interpolate_me( mein, meout)
      complex(8), intent( in) :: mein( wf_fst:wf_lst, wf_fst:wf_lst, wf_kset%nkpt)
      complex(8), intent( out) :: meout( wf_fst:wf_lst, wf_fst:wf_lst, wfint_kset%nkpt)

      !!!!!
      ! correct wf_nst and wf_nwf here
      !!!!!
      integer :: ir, ik, iq, ist
      complex(8), allocatable :: okwan(:,:,:), or(:,:,:), oqwan(:,:), ou(:,:)

      allocate( okwan( wf_fst:wf_lst, wf_fst:wf_lst, wf_kset%nkpt))

#ifdef USEOMP                
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE( ik, ir, ou)
#endif
      allocate( ou( wf_fst:wf_lst, wf_fst:wf_lst))
#ifdef USEOMP                
!$OMP DO  
#endif
      do ik = 1, wf_kset%nkpt
        call zgemm( 'N', 'N', wf_nst, wf_nst, wf_nst, zone, &
             mein( :, :, ik), wf_nst, &
             wf_transform( :, :, ik), wf_nst, zzero, &
             ou, wf_nst)
        call zgemm( 'C', 'N', wf_nst, wf_nst, wf_nst, zone, &
             wf_transform( :, :, ik), wf_nst, &
             ou, wf_nst, zzero, &
             okwan( :, :, ik), wf_nst)
      end do
#ifdef USEOMP                
!$OMP END DO  
#endif
      deallocate( ou)
#ifdef USEOMP                
!$OMP END PARALLEL
#endif

      allocate( or( wf_fst:wf_lst, wf_fst:wf_lst, wfint_nrpt))

      do ist = wf_fst, wf_lst
        call zgemm( 'n', 'n', wf_nst, wf_kset%nkpt, wf_kset%nkpt, zone/wf_kset%nkpt, &
               okwan( ist, :, :), wf_nst, &
               conjg( wfint_pkr), wf_kset%nkpt, zzero, &
               or( ist, :, :), wf_nst)
      end do

      deallocate( okwan)

#ifdef USEOMP                
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE( iq, ir, ou, oqwan)
#endif
      allocate( ou( wf_fst:wf_lst, wf_fst:wf_lst))
      allocate( oqwan( wf_fst:wf_lst, wf_fst:wf_lst))
#ifdef USEOMP                
!$OMP DO  
#endif
      do iq = 1, wfint_kset%nkpt
        oqwan = zzero 
        do ir = 1, wfint_nrpt
          oqwan(:,:) = oqwan(:,:) + or( :, :, ir)*wfint_pqr( iq, ir)
        end do
        call zgemm( 'n', 'n', wf_nst, wf_nst, wf_nst, zone, &
               oqwan, wf_nst, &
               wfint_transform( :, :, iq), wf_nst, zzero, &
               ou, wf_nst)
        call zgemm( 'c', 'n', wf_nst, wf_nst, wf_nst, zone, &
               wfint_transform( :, :, iq), wf_nst, &
               ou, wf_nst, zzero, &
               meout( :, :, iq), wf_nst)
      end do
#ifdef USEOMP                
!$OMP END DO  
#endif
      deallocate( ou, oqwan)
#ifdef USEOMP                
!$OMP END PARALLEL
#endif

      deallocate( or)

    end subroutine wfint_interpolate_me

!--------------------------------------------------------------------------------------

    !BOP
    ! !ROUTINE: wfint_init
    ! !INTERFACE:
    !
    subroutine wfint_interpolate_gwpermat
      ! !USES:
      use m_getunit 
      ! !INPUT PARAMETERS:
      !   int_kset : k-point set on which the interpolation is performed on (in, type k_set)
      ! !DESCRIPTION:
      !   Sets up the interpolation grid and calculates the interpolated eigenenergies as well as 
      !   the corresponding expansion coefficients and phasefactors for the interpolated wavefunctions.
      !
      ! !REVISION HISTORY:
      !   Created July 2017 (SeTi)
      !EOP
      !BOC
      integer :: ik, ist, jst, un, recl, nkpqp, fstqp, lstqp, nk, isym, iq, nkequi, isymequi( wf_kset%nkpt), ikequi( wf_kset%nkpt)
      integer :: lmax, is, ia, ias, l
      real(8) :: vl(3), efermiqp, efermiks, sum
      character(256) :: fname, fxt
      logical :: exist
      integer, allocatable :: gwpervec(:,:), gwpervecint(:,:)
      real(8), allocatable :: evalinks(:,:), evalinqp(:,:), secintval(:), evalqp(:), evalks(:), evalint(:,:), bcks(:,:,:,:), bcqp(:,:,:,:)
      complex(8), allocatable :: evecint(:,:,:), mein(:,:,:), meout(:,:,:), secintvec(:,:), olp(:,:)

      call getunit( un)
      write( fname, '("EVALQP.OUT")')
      inquire( file=trim( fname), exist=exist)
      if( .not. exist) then
        write( *, '("Error (wfint_init): File EVALQP.OUT does not exist!")')
        call terminate
      end if
      inquire( iolength=recl) nkpqp, fstqp, lstqp
      open( un, file=trim( fname), action='read', form='unformatted', access='direct', recl=recl)
      read( un, rec=1), nkpqp, fstqp, lstqp
      close( un)
      if( fstqp .gt. wf_fst) then
        write( *, '("Error (wfint_init): First QP band (",I3,") is greater than first wannierized band (",I3,").")') fstqp, wf_fst
        call terminate
      end if
      if( lstqp .lt. wf_lst) then
        write( *, '("Error (wfint_init): Last QP band (",I3,") is less than last wannierized band (",I3,").")') lstqp, wf_lst
        call terminate
      end if
      allocate( evalqp( fstqp:lstqp))
      allocate( evalks( fstqp:lstqp))
      allocate( evalinks( wf_fst:wf_lst, wf_kset%nkpt))
      allocate( evalinqp( wf_fst:wf_lst, wf_kset%nkpt))

      fxt = filext
      write( filext, '("_GW.OUT")')
      call readfermi
      filext = fxt
      call getunit( un)
      inquire( iolength=recl) nkpqp, fstqp, lstqp, vl, evalqp, evalks, efermiqp, efermiks
      open( un, file=trim( fname), action='read', form='unformatted', access='direct', recl=recl)
      do ik = 1, nkpqp
        read( un, rec=ik) nk, fstqp, lstqp, vl, evalqp, evalks, efermiqp, efermiks
        call findequivkpt( vl, wf_kset, nkequi, isymequi, ikequi)
        do iq = 1, nkequi
          evalinks( :, ikequi( iq)) = evalks( wf_fst:wf_lst)
          evalinqp( :, ikequi( iq)) = evalqp( wf_fst:wf_lst)
        end do
      end do
      close( un)

      lmax = 3
      allocate( bcks( 0:lmax, natmtot, wf_nwf, wfint_kset%nkpt))
      allocate( bcqp( 0:lmax, natmtot, wf_nwf, wfint_kset%nkpt))
      write( fname, '("EXWGT.OUT")')
      inquire( file=trim( fname), exist=exist)
      if( .not. exist) then
        write( *, '("Error (wfint_init): File EXWGT.OUT does not exist!")')
        call terminate
      end if
      call getunit( un)
      open( un, file=trim( fname), action='read', form='formatted')
      read( un, *)
      read( un, *)
      read( un, *)
      read( un, *)
      do ist = 1, wf_nwf
        do iq = 1, wfint_kset%nkpt
          read( un, *) bcks( 0, 1, ist, iq), efermiks, bcks( 1, 1, ist, iq), bcks( 2, 1, ist, iq)
        end do
        read( un, *)
      end do
      close( un)
      allocate( evalint( wf_fst:wf_lst, wfint_kset%nkpt))
      allocate( evecint( wf_fst:wf_lst, wf_fst:wf_lst, wfint_kset%nkpt))
      call wfint_interpolate_eigsys( evalinks)
      evalint = wfint_eval
      evecint = wfint_transform
      !call wfint_interpolate_bandchar( lmax, bcks)
      call wfint_interpolate_eigsys( evalinqp)
      
      allocate( mein( wf_fst:wf_lst, wf_fst:wf_lst, wf_kset%nkpt))
      allocate( meout( wf_fst:wf_lst, wf_fst:wf_lst, wfint_kset%nkpt))
      !mein = zzero
      !do ik = 1, wf_kset%nkpt
      !  do ist = wf_fst, wf_lst
      !    mein( ist, ist, ik) = cmplx( evalinqp( ist, ik) - evalinks( ist, ik), 0, 8)
      !  end do
      !end do
      !call wfint_interpolate_me( mein, meout)

      allocate( secintval( wf_fst:wf_lst))
      allocate( secintvec( wf_fst:wf_lst, wf_fst:wf_lst))
      allocate( olp( wf_fst:wf_lst, wf_fst:wf_lst))
      do iq = 1, wfint_kset%nkpt
        !write( *, '("k-point # ",I5,":",4F12.6)') iq, wfint_kset%vkl( :, iq), wfint_kset%wkpt( iq)

        !call diaghermat( wf_nwf, meout( :, :, iq), secintval, secintvec)
        !write( *, '(1000F11.5)') evalint( :, iq)
        !write( *, '(1000F11.5)') wfint_eval( :, iq)
        !write(*,*)
        !write( *, '(1000F11.5)') wfint_eval( :, iq)-evalint( :, iq)
        !write( *, '(1000F11.5)') secintval
        !call plotmat( secintvec)
        !write(*,*)

        call zgemm( 'c', 'n', wf_nwf, wf_nwf, wf_nwf, zone, &
             evecint( :, :, iq), wf_nwf, &
             wfint_transform( :, :, iq), wf_nwf, zzero, &
             olp, wf_nwf)
        !do ias = 1, natmtot
        !  do l = 0, lmax
             call dgemv( 't', wf_nwf, wf_nwf, 1.d0, &
                  abs( olp)**2, wf_nwf, &
                  bcks( 1, 1, :, iq), 1, 0.d0, &
                  bcqp( 1, 1, :, iq), 1)
        !  end do
        !end do
        !gwpervecint( :, 1) = 0
        !do ist = wf_fst, wf_lst
        !  ik = maxloc( abs( gwpermatin( :, ist, 1)), 1)
        !  if( gwpervecint( ik, 1) .eq. 0) then
        !    gwpervecint( ik, 1) = ist
        !  end if
        !  gwpervecint( ist, 2) = ik
        !  ik = maxloc( abs( gwpermatin( ist, :, 1)), 1)
        !  gwpervecint( ist, 4) = ik
        !end do
        !!write( *, '(1000I3)') gwpervecint( :, 3)
        !!write( *, '(1000I3)') gwpervecint( :, 2)
        !!write( *, '(1000I3)') gwpervecint( :, 1)
        !!write( *, '(1000I3)') gwpervecint( :, 4)
        !write(*,*)
        !do ist = wf_fst, wf_lst
        !  ik = gwpervecint( ist, 4)
        !  write( *, '(I3,9F11.5)') ist, evalin( ist, iq), wfint_eval( ist, iq), wfint_eval( ik, iq), evalqp( ist), 0.d0, 0.d0, &
        !      sum( abs( gwpermatin( ist, :, 1))**2), &
        !      wfint_eval( ik, iq) - evalin( ist, iq), evalqp( ist) - evalin( ist, iq)
        !end do
        !!call plotmat( zone*abs( gwpermatin( :, :, 1)))
        !!write(*,*)
        !write(*,*)
      end do

      write( fxt, '("_GW_NEW.OUT")')
      !do is = 1, nspecies
      !  do ia = 1, natoms( is)
      !    ias = idxas( ia, is)
      !    write( fname, '("BAND_WANNIER_S", I2.2, "_A", I4.4)') is, ia
          write( fname, '("BAND_WANNIER_EX")')
          call getunit( un)
          open( un, file=trim( fname)//trim( fxt), action='write', form='formatted')

          do ist = 1, wf_nwf
            do iq = 1, wfint_kset%nkpt
              !sum = 0.d0
              !do l = 0, lmax
              !  sum = sum + bcqp( l, ias, ist, iq)
              !end do
              write( un, '(2G18.10, 20E24.16)') bcks( 0, 1, ist, iq), wfint_eval( ist, iq), bcqp( 1, 1, ist, iq), bcks( 2, 1, ist, iq)
            end do
            write( un, *)
          end do
          close( un)
      !  end do
      !end do
      write(*,*)
      write(*, '("Info (wfutil_bandstructure):")')
      !write(*,*) "band structure plot written to BAND_WANNIER_Sss_Aaaaa"//trim( fxt)
      !write(*, '("	for all species and atoms")')
      return
    end subroutine wfint_interpolate_gwpermat
    !EOC

!--------------------------------------------------------------------------------------

    subroutine wfint_interpolate_eigvec
      integer :: ik, iq, ig, igk, ir, ist
      integer :: ngkmaxint, nmatmaxint

      complex(8), allocatable :: evecfv(:,:,:), evectmp(:,:), evecrotk(:,:), evecrotq(:,:)

      call generate_Gk_vectors( wfint_Gkset, wfint_kset, wf_Gset, wf_Gkset%gkmax)
      ngkmaxint = wfint_Gkset%ngkmax
      nmatmaxint = ngkmaxint + nlotot

      allocate( evecfv( nmatmax, nstfv, nspinor))
      allocate( evectmp( wf_Gset%ngrtot, wf_fst:wf_lst))
      allocate( evecrotk( wf_Gset%ngrtot, wf_nwf))
      allocate( evecrotq( wf_Gset%ngrtot, wf_nwf))
      
      if( allocated( wfint_evec)) deallocate( wfint_evec)
      allocate( wfint_evec( nmatmaxint, wf_nwf, wfint_kset%nkpt))
      wfint_evec = zzero

      do ik = 1, wf_kset%nkpt
        write(*,*) ik
        call wannier_getevec( ik, evecfv)
        evectmp = zzero
#ifdef USEOMP
!$omp parallel default( shared) private( igk, ig)
!$omp do
#endif
        do igk = 1, wf_Gkset%ngk( 1, ik)
          ig = wf_Gkset%igkig( igk, 1, ik)
          evectmp( ig, :) = evecfv( igk, wf_fst:wf_lst, 1)
        end do
#ifdef USEOMP
!$omp end do
!$omp end parallel
#endif
        call zgemm( 'n', 'n', wf_Gset%ngrtot, wf_nwf, wf_nst, zone, &
               evectmp, wf_Gset%ngrtot, &
               wf_transform( :, :, ik), wf_nst, zzero, &
               evecrotk, wf_Gset%ngrtot)
        do iq = 1, wfint_kset%nkpt
          call zgemm( 'n', 'n', wf_Gset%ngrtot, wf_nwf, wf_nwf, cmplx( wfint_phase( ik, iq), 0, 8), &
                 evecrotk, wf_Gset%ngrtot, &
                 wfint_transform( :, :, iq), wf_nwf, zzero, &
                 evecrotq, wf_Gset%ngrtot)
#ifdef USEOMP
!$omp parallel default( shared) private( igk, ig)
!$omp do
#endif
          do igk = 1, wfint_Gkset%ngk( 1, iq)
            ig = wfint_Gkset%igkig( igk, 1, iq)
            wfint_evec( igk, :, iq) = wfint_evec( igk, :, iq) + evecrotq( ig, :)
          end do
#ifdef USEOMP
!$omp end do
!$omp end parallel
#endif
        end do
      end do

      deallocate( evecfv, evectmp, evecrotk, evecrotq)
      
      return
    end subroutine wfint_interpolate_eigvec


!--------------------------------------------------------------------------------------
! helper functions

    subroutine wfint_putwfmt( ik, ias, wfmttp)
      use m_getunit
    
      !!!!!
      ! correct wf_nst and wf_nwf here
      !!!!!
      integer, intent( in) :: ik, ias
      complex(8), intent( in) :: wfmttp( lmmaxvr, nrcmtmax, wf_fst:wf_lst)
    
      integer :: un, recl, offset
      character(256) :: filename
    
      inquire( iolength=recl) wf_kset%vkl( :, ik), ias, wf_fst, wf_lst, lmmaxvr, nrcmtmax, natmtot, wfmttp
    
      filename = 'WANNIER_WFMT.TMP'
      call getunit( un)
      open( un, file=filename, action='write', form='unformatted', access='direct', recl=recl)
      offset = (ik-1)*natmtot + ias
      write( un, rec=offset) wf_kset%vkl( :, ik), ias, wf_fst, wf_lst, lmmaxvr, nrcmtmax, natmtot, wfmttp
      close( un)
    
      return
    end subroutine wfint_putwfmt
    
    subroutine wfint_putwfir( ik, wfir)
      use m_getunit
    
      !!!!!
      ! correct wf_nst and wf_nwf here
      !!!!!
      integer, intent( in) :: ik
      complex(8), intent( in) :: wfir( wf_Gset%ngrtot, wf_fst:wf_lst)
    
      integer :: un, recl
      character(256) :: filename
    
      inquire( iolength=recl) wf_kset%vkl( :, ik), wf_fst, wf_lst, wf_Gset%ngrtot, wfir
    
      filename = 'WANNIER_WFIR.TMP'
      call getunit( un)
      open( un, file=filename, action='write', form='unformatted', access='direct', recl=recl)
      write( un, rec=ik) wf_kset%vkl( :, ik), wf_fst, wf_lst, wf_Gset%ngrtot, wfir
      close( un)
    
      return
    end subroutine wfint_putwfir
    
    subroutine wfint_getwfmt( ik, ias, wfmttp)
      use m_getunit
    
      !!!!!
      ! correct wf_nst and wf_nwf here
      !!!!!
      integer, intent( in) :: ik, ias
      complex(8), intent( out) :: wfmttp( lmmaxvr*nrcmtmax, wf_fst:wf_lst)
    
      integer :: i, un, recl, offset, fst, lst, ias_, lmmaxvr_, nrcmtmax_, natmtot_
      real(8) :: vl(3)
      character(256) :: filename
      logical :: exist
    
      inquire( iolength=recl) wf_kset%vkl( :, ik), ias, wf_fst, wf_lst, lmmaxvr, nrcmtmax, natmtot, wfmttp
    
      filename = 'WANNIER_WFMT.TMP'
      call getunit( un)
    
      do i = 1, 100
        inquire( file=filename, exist=exist)
        if( exist) then
          open( un, file=filename, action='read', form='unformatted', access='direct', recl=recl)
          exit
        else
          call system( 'sync')
          write(*,*) "Waiting for other process to write"
          call sleep( 1)
        end if
      end do
    
      offset = (ik-1)*natmtot + ias
      read( un, rec=offset) vl, ias_, fst, lst, lmmaxvr_, nrcmtmax_, natmtot_, wfmttp
      if( norm2( vl - wf_kset%vkl( :, ik)) .gt. input%structure%epslat) then
        write(*, '("Error (wannier_getwfir): differing vectors for k-point ",I8)') ik
        Write (*, '(" current	   : ", 3G18.10)') wf_kset%vkl (:, ik)
        Write (*, '(" WANNIER_WFMT.TMP : ", 3G18.10)') vl
        Write (*, '(" file	  : ", a      )') filename
        stop
      end if
      if( (fst .ne. wf_fst) .or. (lst .ne. wf_lst)) then
        write(*, '("Error (wannier_getwfir): invalid band ranges")')
        Write (*, '(" current	   : ", 2I8)') wf_fst, wf_lst
        Write (*, '(" WANNIER_WFMT.TMP : ", 2I8)') fst, lst
        Write (*, '(" file	  : ", a      )') filename
        stop
      end if
      if( ias_ .ne. ias) then
        write(*, '("Error (wannier_getwfir): differing atom-index")')
        Write (*, '(" current	   : ", I8)') ias
        Write (*, '(" WANNIER_WFMT.TMP : ", I8)') ias_
        Write (*, '(" file	  : ", a      )') filename
        stop
      end if
      if( nrcmtmax_ .ne. nrcmtmax) then
        write(*, '("Error (wannier_getwfir): invalid number of radial points")')
        Write (*, '(" current	   : ", I8)') nrcmtmax
        Write (*, '(" WANNIER_WFMT.TMP : ", I8)') nrcmtmax_
        Write (*, '(" file	  : ", a      )') filename
        stop
      end if
      if( lmmaxvr_ .ne. lmmaxvr) then
        write(*, '("Error (wannier_getwfir): invalid number of angular points")')
        Write (*, '(" current	   : ", I8)') lmmaxvr
        Write (*, '(" WANNIER_WFMT.TMP : ", I8)') lmmaxvr_
        Write (*, '(" file	  : ", a      )') filename
        stop
      end if
      if( natmtot_ .ne. natmtot) then
        write(*, '("Error (wannier_getwfir): invalid number of atoms")')
        Write (*, '(" current	   : ", I8)') natmtot
        Write (*, '(" WANNIER_WFMT.TMP : ", I8)') natmtot_
        Write (*, '(" file	  : ", a      )') filename
        stop
      end if
      close( un)
    
      return
    end subroutine wfint_getwfmt
    
    subroutine wfint_getwfir( ik, wfir)
      use m_getunit
    
      !!!!!
      ! correct wf_nst and wf_nwf here
      !!!!!
      integer, intent( in) :: ik
      complex(8), intent( out) :: wfir( wf_Gset%ngrtot, wf_fst:wf_lst)
    
      integer :: i, un, recl, fst, lst, ng
      real(8) :: vl(3)
      character(256) :: filename
      logical :: exist
    
      inquire( iolength=recl) wf_kset%vkl( :, ik), wf_fst, wf_lst, wf_Gset%ngrtot, wfir
    
      filename = 'WANNIER_WFIR.TMP'
      call getunit( un)
    
      do i = 1, 100
        inquire( file=filename, exist=exist)
        if( exist) then
          open( un, file=filename, action='read', form='unformatted', access='direct', recl=recl)
          exit
        else
          call system( 'sync')
          write(*,*) "Waiting for other process to write"
          call sleep( 1)
        end if
      end do
    
      open( un, file=filename, action='read', form='unformatted', access='direct', recl=recl)
      read( un, rec=ik) vl, fst, lst, ng, wfir
      if( norm2( vl - wf_kset%vkl( :, ik)) .gt. input%structure%epslat) then
        write(*, '("Error (wannier_getwfir): differing vectors for k-point ",I8)') ik
        Write (*, '(" current	   : ", 3G18.10)') wf_kset%vkl (:, ik)
        Write (*, '(" WANNIER_WFIR.TMP : ", 3G18.10)') vl
        Write (*, '(" file	  : ", a      )') filename
        stop
      end if
      if( (fst .ne. wf_fst) .or. (lst .ne. wf_lst)) then
        write(*, '("Error (wannier_getwfir): invalid band ranges")')
        Write (*, '(" current	   : ", 2I8)') wf_fst, wf_lst
        Write (*, '(" WANNIER_WFIR.TMP : ", 2I8)') fst, lst
        Write (*, '(" file	  : ", a      )') filename
        stop
      end if
      if( ng .ne. wf_Gset%ngrtot) then
        write(*, '("Error (wannier_getwfir): invalid number of spatial points")')
        Write (*, '(" current	   : ", I8)') wf_Gset%ngrtot
        Write (*, '(" WANNIER_WFIR.TMP : ", I8)') ng
        Write (*, '(" file	  : ", a      )') filename
        stop
      end if
      close( un)
    
      return
    end subroutine wfint_getwfir
    
    subroutine wfint_destroywf
      use m_getunit
    
      integer :: un
      logical :: exist
    
      inquire( file='WANNIER_WFMT.TMP', exist=exist)
      if( exist) then
        call getunit( un)
        open( un, file='WANNIER_WFMT.TMP')
        close( un, status='delete')
      end if
    
      inquire( file='WANNIER_WFIR.TMP', exist=exist)
      if( exist) then
        call getunit( un)
        open( un, file='WANNIER_WFIR.TMP')
        close( un, status='delete')
      end if
    
      return
    end subroutine wfint_destroywf

end module mod_wfint
