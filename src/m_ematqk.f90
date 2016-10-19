module m_ematqk
  use modinput
  use mod_atoms
  use mod_APW_LO
  use mod_muffin_tin
  use mod_constants
  use mod_lattice
  use mod_kpoint
  use mod_Gvector
  use mod_Gkvector
  use mod_eigenvalue_occupancy

  implicit none
  private

  logical :: initialized = .false.
  integer :: nlmomax, lmaxapw, lmaxexp
  real(8) :: vecql(3), vecqc(3), vecgc(3)
  integer :: vecgl(3)

  integer, allocatable :: nlmo(:), lmo2l(:,:), lmo2m(:,:), lmo2o(:,:), lm2l(:)
  complex(8), allocatable :: rigntaa(:,:,:), rigntal(:,:,:), rigntla(:,:,:), rigntll(:,:,:)

  public :: emat_init, emat_genemat

! variable

! methods
  contains
      subroutine emat_init( vecql_, vecgc_, lmaxapw_, lmaxexp_)
          integer, intent( in) :: lmaxapw_, lmaxexp_
          real(8), intent( in) :: vecql_(3), vecgc_(3)

          integer :: l1, l2, l3, m1, m2, m3, o1, o2, lm1, lm2, lm3, is, ia, ias, i
          integer :: lmo1, lmo2, ilo1, ilo2, idxlo1, idxlo2, idxlostart
          real(8) :: gnt, gaunt, qgc, tp(2), vec1(3), vec2(3)
          complex(8) :: strf, ylm( (lmaxexp_ + 1)**2)

          integer, allocatable :: idxgnt(:,:,:)
          real(8), allocatable :: listgnt(:,:,:), riaa(:,:,:,:,:), rial(:,:,:,:), rill(:,:,:)

          external :: gaunt

          ! check wether module was already initialized
          ! if, then destroy first
          if( initialized) call emat_destroy
          
          ! start initialization
          
          lmaxapw = min( lmaxapw_, input%groundstate%lmaxapw)
          lmaxexp = lmaxexp_
          vecql(:) = vecql_(:)
          vecgc(:) = vecgc_(:)
          call r3mv( bvec, vecql, vecqc)
          call r3mv( binv, vecgc, vec1)
          vec2 = vec1 - nint( vec1)
          if( norm2( vec2) .lt. input%structure%epslat) then
            vecgl = nint( vec1)
          else
            write( *, '("ERROR (emat_init): vecgc is not a valid reciprocal lattice vector")')
            stop
          end if
          
          ! count combined (l,m,o) indices and build index maps
          allocate( nlmo( nspecies))
          allocate( lmo2l( (lmaxapw + 1)**2*apwordmax, nspecies), &
                    lmo2m( (lmaxapw + 1)**2*apwordmax, nspecies), &
                    lmo2o( (lmaxapw + 1)**2*apwordmax, nspecies))
          nlmomax = 0
          do is = 1, nspecies
            nlmo( is) = 0
            do l1 = 0, lmaxapw
              do o1 = 1, apword( l1, is)
                do m1 = -l1, l1
                  nlmo( is) = nlmo( is) + 1
                  lmo2l( nlmo( is), is) = l1
                  lmo2m( nlmo( is), is) = m1
                  lmo2o( nlmo( is), is) = o1
                end do
              end do
            end do
            nlmomax = max( nlmomax, nlmo( is))
          end do

          allocate( lm2l( (lmaxexp + 1)**2))
          do l1 = 0, lmaxexp
            do m1 = -l1, l1
              lm1 = idxlm( l1, m1)
              lm2l( lm1) = l1
            end do
          end do

          ! build non-zero Gaunt list
          allocate( idxgnt( lmaxapw + 1, (lmaxapw + 1)**2, (lmaxapw + 1)**2), &
                    listgnt( lmaxapw + 1, (lmaxapw + 1)**2, (lmaxapw + 1)**2))
          idxgnt(:,:,:) = 0
          listgnt(:,:,:) = 0.d0
          do l3 = 0, lmaxapw
            do m3 = -l3, l3
              lm3 = idxlm( l3, m3)

              do l1 = 0, lmaxapw
                do m1 = -l1, l1
                  lm1 = idxlm( l1, m1)

                  i = 0
                  do l2 = 0, lmaxexp
                    do m2 = -l2, l2
                      lm2 = idxlm( l2, m2)
                      gnt = gaunt( l1, l2, l3, m1, m2, m3)
                      if( gnt .ne. 0.d0) then
                        i = i + 1
                        listgnt( i, lm1, lm3) = gnt
                        idxgnt( i, lm1, lm3) = lm2
                      end if
                    end do
                  end do

                end do
              end do
            
            end do
          end do
          
          ! compute radial integrals times Gaunt and expansion prefactor
          allocate( rigntaa( nlmomax, nlmomax, natmtot), &
                    rigntal( nlmomax, nlotot, natmtot), &
                    rigntla( nlotot, nlmomax, natmtot), &
                    rigntll( nlotot, nlotot, natmtot))
          rigntaa(:,:,:) = zzero
          rigntal(:,:,:) = zzero
          rigntla(:,:,:) = zzero
          rigntll(:,:,:) = zzero
          allocate( riaa( 0:lmaxexp, 0:lmaxapw, apwordmax, 0:lmaxapw, apwordmax), &
                    rial( 0:lmaxexp, 0:lmaxapw, apwordmax, nlomax), &
                    rill( 0:lmaxexp, nlomax, nlomax))
          ! generate radial functions
          call genapwfr
          call genlofr
          ! multiply radial integral with Gaunt coefficients and expansion prefactor
          idxlostart = 0
          ! generate spherical harmonics
          call sphcrd( vecqc(:) + vecgc(:), qgc, tp)
          call genylm( lmaxexp, tp, ylm)

          do is = 1, nspecies
            do ia = 1, natoms( is)
              ias = idxas( ia, is)
              strf = exp( -zi*dot_product( vecqc(:) + vecgc(:), atposc( :, ia, is)))
              ! generate radial integral
              call emat_genri( is, ia, riaa, rial, rill)
              ! APW-APW
              do lmo2 = 1, nlmo( is)
                l2 = lmo2l( lmo2, is)
                m2 = lmo2m( lmo2, is)
                o2 = lmo2o( lmo2, is)
                lm2 = idxlm( l2, m2)
                do lmo1 = 1, nlmo( is)
                  l1 = lmo2l( lmo1, is)
                  m1 = lmo2m( lmo1, is)
                  o1 = lmo2o( lmo1, is)
                  lm1 = idxlm( l1, m1)
                  i = 1
                  do while( idxgnt( i, lm1, lm2) .ne. 0)
                    lm3 = idxgnt( i, lm1, lm2)
                    l3 = lm2l( lm3)
                    rigntaa( lmo1, lmo2, ias) = rigntaa( lmo1, lmo2, ias) + &
                        strf*conjg( zil( l3))*conjg( ylm( lm3))*listgnt( i, lm1, lm2)*riaa( l3, l1, o1, l2, o2)
                    i = i + 1
                  end do
                end do
              end do

              do lmo1 = 1, nlmo( is)
                l1 = lmo2l( lmo1, is)
                m1 = lmo2m( lmo1, is)
                o1 = lmo2o( lmo1, is)
                lm1 = idxlm( l1, m1)
                idxlo1 = 0
                do ilo1 = 1, nlorb( is)
                  l2 = lorbl( ilo1, is)
                  do m2 = -l2, l2
                    lm2 = idxlm( l2, m2)
                    idxlo1 = idxlo1 + 1
                    ! APW-LO
                    i = 1
                    do while( idxgnt( i, lm1, lm2) .ne. 0)
                      lm3 = idxgnt( i, lm1, lm2)
                      l3 = lm2l( lm3)
                      rigntal( lmo1, idxlostart+idxlo1, ias) = rigntal( lmo1, idxlostart+idxlo1, ias) + &
                          strf*conjg( zil( l3))*conjg( ylm( lm3))*listgnt( i, lm1, lm2)*rial( l3, l1, o1, ilo1)
                      i = i + 1
                    end do
                    ! LO-APW
                    i = 1
                    do while( idxgnt( i, lm2, lm1) .ne. 0)
                      lm3 = idxgnt( i, lm2, lm1)
                      l3 = lm2l( lm3)
                      rigntla( idxlostart+idxlo1, lmo1, ias) = rigntla( idxlostart+idxlo1, lmo1, ias) + &
                          strf*conjg( zil( l3))*conjg( ylm( lm3))*listgnt( i, lm2, lm1)*rial( l3, l1, o1, ilo1)
                      i = i + 1
                    end do
                  end do
                end do
              end do

              ! LO-LO
              idxlo2 = 0
              do ilo2 = 1, nlorb( is)
                l2 = lorbl( ilo2, is)
                do m2 = -l2, l2
                  lm2 = idxlm( l2, m2)
                  idxlo2 = idxlo2 + 1
                  idxlo1 = 0
                  do ilo1 = 1, nlorb( is)
                    l1 = lorbl( ilo1, is)
                    do m1 = -l1, l1
                      lm1 = idxlm( l1, m1)
                      idxlo1 = idxlo1 + 1
                      i = 1
                      do while( idxgnt( i, lm1, lm2) .ne. 0)
                        lm3 = idxgnt( i, lm1, lm2)
                        l3 = lm2l( lm3)
                        rigntll( idxlostart+idxlo1, idxlostart+idxlo2, ias) = rigntll( idxlostart+idxlo1, idxlostart+idxlo2, ias) + &
                            strf*conjg( zil( l3))*conjg(ylm( lm3))*listgnt( i, lm1, lm2)*rill( l3, ilo1, ilo2)
                        i = i + 1
                      end do
                    end do
                  end do
                end do
              end do
              
              idxlostart = idxlostart + idxlo2

            end do ! atoms
          end do !species
          
          initialized = .true.
          deallocate( idxgnt, listgnt, riaa, rial, rill)
          return
      end subroutine emat_init
      
      subroutine emat_genri( is, ia, riaa, rial, rill)
          integer, intent( in) :: is, ia
          real(8), intent( out) :: riaa( 0:lmaxexp, 0:lmaxapw, apwordmax, 0:lmaxapw, apwordmax)
          real(8), intent( out) :: rial( 0:lmaxexp, 0:lmaxapw, apwordmax, nlomax)
          real(8), intent( out) :: rill( 0:lmaxexp, nlomax, nlomax)

          integer :: ias, ir, nr, l1, l2, l3, o1, o2, ilo1, ilo2
          real(8) :: x, qgc, tp(2)

          real(8), allocatable :: jlqgr(:,:), fr(:), gf(:), cf(:,:)
          
          riaa(:,:,:,:,:) = 0.d0
          rial(:,:,:,:) = 0.d0
          rill(:,:,:) = 0.d0
          
          ias = idxas( ia, is)
          call sphcrd( vecqc(:) + vecgc(:), qgc, tp)
          nr = nrmt( is)
          ! generate spherical Bessel functions
          allocate( jlqgr( 0:lmaxexp, nr))
          do ir = 1, nr
            x = qgc*spr( ir, is)
            call sbessel( lmaxexp, x, jlqgr( :, ir))
          end do

          allocate( fr( nr), gf( nr), cf( 3, nr))
          ! APW-APW
          do l2 = 0, lmaxapw
            do o2 = 1, apword( l2, is)
              do l1 = 0, lmaxapw
                do o1 = 1, apword( l1, is)
                  do l3 = 0, lmaxexp
                    do ir = 1, nr
                      fr( ir) = apwfr( ir, 1, o1, l1, ias)*jlqgr( l3, ir)*apwfr( ir, 1, o2, l2, ias)*spr( ir, is)**2
                    end do
                    call fderiv( -1, nr, spr( :, is), fr, gf, cf)
                    riaa( l3, l1, o1, l2, o2) = gf( nr)
                  end do
                end do
              end do
            end do
          end do

          ! APW-LO
          do ilo1 = 1, nlorb( is)
            do l1 = 0, lmaxapw
              do o1 = 1, apword( l1, is)
                do l3 = 0, lmaxexp
                  do ir = 1, nr
                    fr( ir) = apwfr( ir, 1, o1, l1, ias)*jlqgr( l3, ir)*lofr( ir, 1, ilo1, ias)*spr( ir, is)**2
                  end do
                  call fderiv( -1, nr, spr( :, is), fr, gf, cf)
                  rial( l3, l1, o1, ilo1) = gf( nr)
                end do
              end do
            end do
          end do

          ! LO-LO
          do ilo2 = 1, nlorb( is)
            do ilo1 = 1, nlorb( is)
              do l3 = 0, lmaxexp
                do ir = 1, nr
                  fr( ir) = lofr( ir, 1, ilo1, ias)*jlqgr( l3, ir)*lofr( ir, 1, ilo2, ias)*spr( ir, is)**2
                end do
                call fderiv( -1, nr, spr( :, is), fr, gf, cf)
                rill( l3, ilo1, ilo2) = gf( nr)
              end do
            end do
          end do

          deallocate( jlqgr, fr, gf, cf)
          return
      end subroutine emat_genri
      
      subroutine emat_genemat( ik, ikq, fst1, nst1, fst2, nst2, evec1, evec2, emat)
          use modxs, only : fftmap_type
          integer, intent( in) :: ik, ikq, fst1, nst1, fst2, nst2
          complex(8), intent( in) :: evec1( ngkmax+nlotot, nstfv), evec2( ngkmax+nlotot, nstfv)
          complex(8), intent( out) :: emat( nst1, nst2)

          integer :: iv(3), ngkq, i, is, ia, ias, l, m, o, lmo, lm
          integer :: ig1, ig2
          real(8) :: t1, veckql(3), veckqc(3), g1(3), g2(3), gs(3), glen
          
          integer :: ix, shift(3), ig, ist1, ist2, igs
          real(8) :: emat_gmax
          type( fftmap_type) :: fftmap
          complex(8), allocatable :: zfft0(:,:), zfftcf(:), zfftres(:), zfft(:)

          integer, allocatable :: igkqig(:) 
          real(8), allocatable :: vecgkql(:,:), vecgkqc(:,:), gkqc(:), tpgkqc(:,:)
          complex(8), allocatable :: sfacgkq(:,:), apwalm1(:,:,:,:), apwalm2(:,:,:,:), apwalm3(:,:,:,:)
          complex(8), allocatable :: blockmt(:,:), auxmat(:,:), match_combined1(:,:), match_combined2(:,:)
          complex(8), allocatable :: aamat(:,:), almat(:,:), lamat(:,:)
          
          emat = zzero

          ! check if q-vector is zero
          t1 = vecql(1)**2 + vecql(2)**2 + vecql(3)**2
          if( t1 .lt. input%structure%epslat) then
            do i = 1, min( nst1, nst2)
              emat( i, i) = zone
            end do
            return
          end if

          ! find matching coefficients for k-point k
          allocate( apwalm1( ngkmax, apwordmax, lmmaxapw, natmtot))
          apwalm1 = zzero
          call match( ngk( 1, ik), gkc( :, 1, ik), tpgkc( :, :, 1, ik), sfacgk( :, :, 1, ik), apwalm1)
          ! k+q-vector in lattice coordinates
          veckql(:) = vkl( :, ik) + vecql(:)
          ! map vector components to [0,1) interval
          call r3frac( input%structure%epslat, veckql, iv)
          ! k+q-vector in Cartesian coordinates
          call r3mv( bvec, veckql, veckqc)
          ! generate the G+k+q-vectors
          allocate( igkqig( ngkmax), vecgkql( 3, ngkmax), vecgkqc( 3, ngkmax), gkqc( ngkmax), tpgkqc( 2, ngkmax))
          call gengpvec( veckql, veckqc, ngkq, igkqig, vecgkql, vecgkqc, gkqc, tpgkqc)
          ! generate the structure factors
          allocate( sfacgkq( ngkmax, natmtot))
          call gensfacgp( ngkq, vecgkqc, ngkmax, sfacgkq)
          ! find the matching coefficients for k-point k+q
          allocate( apwalm2( ngkmax, apwordmax, lmmaxapw, natmtot))
          allocate( apwalm3( ngkmax, apwordmax, lmmaxapw, natmtot))
          apwalm2 = zzero
          call match( ngkq, gkqc, tpgkqc, sfacgkq, apwalm2)
          !call match( ngk( 1, ikq), gkc( :, 1, ikq), tpgkc( :, :, 1, ikq), sfacgk( :, :, 1, ikq), apwalm2)
          
          ! build block matrix
          ! [_AA_|_AL_]
          ! [ LA | LL ]
          allocate( blockmt( ngk( 1, ik)+nlotot, ngkq+nlotot))
          allocate( auxmat( nlmomax, ngkq))
          allocate( match_combined1( nlmomax, ngk( 1, ik)), &
                    match_combined2( nlmomax, ngkq))
          allocate( aamat( ngk( 1, ik), ngkq), &
                    almat( ngk( 1, ik), nlotot), &
                    lamat( nlotot, ngkq))
        
          blockmt(:,:) = zzero

          do is = 1, nspecies
            do ia = 1, natoms( is)
              ias = idxas( ia, is)
              ! write combined matching coefficient matrices
              match_combined1(:,:) = zzero
              match_combined2(:,:) = zzero
              do lmo = 1, nlmo( is)
                l = lmo2l( lmo, is)
                m = lmo2m( lmo, is)
                o = lmo2o( lmo, is)
                lm = idxlm( l, m)
                match_combined1( lmo, :) = apwalm1( 1:ngk( 1, ik), o, lm, ias)
                match_combined2( lmo, :) = apwalm2( 1:ngkq, o, lm, ias)
              end do
              ! sum up block matrix
              ! APW-APW
              auxmat(:,:) = zzero
              call ZGEMM( 'N', 'N', nlmo( is), ngkq, nlmo( is), zone, &
                  rigntaa( 1:nlmo( is), 1:nlmo( is), ias), nlmo( is), &
                  match_combined2( 1:nlmo( is), :), nlmo( is), zzero, &
                  auxmat( 1:nlmo( is), :), nlmo( is))
              call ZGEMM( 'C', 'N', ngk( 1, ik), ngkq, nlmo( is), zone, &
                  match_combined1( 1:nlmo( is), :), nlmo( is), &
                  auxmat( 1:nlmo( is), :), nlmo( is), zzero, &
                  aamat, ngk( 1, ik))
              blockmt( 1:ngk( 1, ik), 1:ngkq) = blockmt( 1:ngk( 1, ik), 1:ngkq) + aamat(:,:)
              ! APW-LO
              call ZGEMM( 'C', 'N', ngk( 1, ik), nlotot, nlmo( is), zone, &
                  match_combined1( 1:nlmo( is), :), nlmo( is), &
                  rigntal( 1:nlmo( is), :, ias), nlmo( is), zzero, &
                  almat, ngk( 1, ik))
              blockmt( 1:ngk( 1, ik), (ngkq+1):(ngkq+nlotot)) = blockmt( 1:ngk( 1, ik), (ngkq+1):(ngkq+nlotot)) + almat(:,:)
              ! LO-APW
              call ZGEMM( 'N','N', nlotot, ngkq, nlmo( is), zone, &
                  rigntla( :, 1:nlmo( is), ias), nlotot, &
                  match_combined2( 1:nlmo( is), :), nlmo( is), zzero, &
                  lamat, nlotot)
              blockmt( (ngk( 1, ik)+1):(ngk( 1, ik)+nlotot), 1:ngkq) = blockmt( (ngk( 1, ik)+1):(ngk( 1, ik)+nlotot), 1:ngkq) + lamat(:,:)
              ! LO-LO
              blockmt( (ngk( 1, ik)+1):(ngk( 1, ik)+nlotot), (ngkq+1):(ngkq+nlotot)) = blockmt( (ngk( 1, ik)+1):(ngk( 1, ik)+nlotot), (ngkq+1):(ngkq+nlotot)) + rigntll( :, :, ias)

            end do
          end do

          ! compute final total muffin tin contribution
          deallocate( auxmat)
          allocate( auxmat( ngk( 1, ik)+nlotot, nst2))
          call ZGEMM( 'N', 'N', ngk( 1, ik)+nlotot, nst2, ngkq+nlotot, zone, &
              blockmt(:,:), ngk( 1, ik)+nlotot, &
              evec2( 1:(ngkq+nlotot), fst2:(fst2+nst2-1)), ngkq+nlotot, zzero, &
              auxmat(:,:), ngk( 1, ik)+nlotot)
          call ZGEMM( 'C', 'N', nst1, nst2, ngk( 1, ik)+nlotot, cmplx( fourpi, 0.d0, 8), &
              evec1( 1:(ngk( 1, ik)+nlotot), fst1:(fst1+nst1-1)), ngk( 1, ik)+nlotot, &
              auxmat(:,:), ngk( 1, ik)+nlotot, zzero, &
              emat(:,:), nst1)
          
          !write(*,*) ik
          !write(*,*) vecql
          !do is = 1, nst1
          !  do ia = 1, nst2
          !    write( *, '(2I3,3x,SP,E23.16,E23.16,"i")') is, ia, emat( is, ia)
          !  end do
          !end do
          
          !--------------------------------------!
          !     interstitial matrix elements     !
          !--------------------------------------!
 
                !ikq = ikmapikq (ik, iq)
          veckql(:) = vkl( :, ik) + vecql(:)        !vkql = veckql
                
          ! umklapp treatment
          do ix = 1, 3
            if( veckql( ix) .ge. 1d0-1d-13) then
              shift( ix) = -1
            else
              shift( ix) = 0
            endif
          enddo
          
          emat_gmax = 2*gkmax! +input%xs%gqmax
          
          call genfftmap( fftmap, emat_gmax)
          allocate( zfft0( fftmap%ngrtot+1, nst1))
          zfft0 = zzero
          
          allocate( zfftcf( fftmap%ngrtot+1))
          zfftcf = zzero
          do ig = 1, ngvec
            if( gc( ig) .lt. emat_gmax) then
             zfftcf( fftmap%igfft( ig)) = cfunig( ig)
            endif
          enddo
          call zfftifc( 3, fftmap%ngrid, 1, zfftcf)
          
#ifdef USEOMP
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE(ist1,ig)
!$OMP DO
#endif
          do ist1 = 1, nst1
            do ig = 1, ngk( 1, ik) !ngk0 ?
              zfft0( fftmap%igfft( igkig( ig, 1, ik)), ist1) = evec1( ig, fst1+ist1-1)
            enddo
            call zfftifc( 3, fftmap%ngrid, 1, zfft0( :, ist1))
            zfft0( :, ist1) = conjg( zfft0( :, ist1))*zfftcf(:) 
          enddo
#ifdef USEOMP
!$OMP END DO
!$OMP END PARALLEL
#endif
             
#ifdef USEOMP
!!$OMP PARALLEL DEFAULT(SHARED) PRIVATE(ist1,ist2,ig,zfft,iv,igs,zfftres,igq)
!!$OMP PARALLEL DEFAULT(SHARED) PRIVATE(ist1,ist2,ig,zfft,iv,igs,zfftres)
#endif
          allocate( zfftres( fftmap%ngrtot+1))
          allocate( zfft( fftmap%ngrtot+1))
#ifdef USEOMP
!!$OMP DO
#endif
          do ist2 = 1, nst2
            zfft = zzero
            if( sum( shift) .ne. 0) then
              do ig = 1, ngkq !ngkq
                iv = ivg( :, igkqig( ig)) + shift
                igs = ivgig( iv(1), iv(2), iv(3))
                zfft( fftmap%igfft( igs)) = evec2( ig, fst2+ist2-1)
              enddo
            else
              do ig = 1, ngkq !ngkq
                zfft( fftmap%igfft( igkqig( ig))) = evec2( ig, fst2+ist2-1)
                !zfft( fftmap%igfft( igkig( ig, 1, ikq))) = evec2( ig, fst2+ist2-1)
              enddo
            endif
          
            call zfftifc( 3, fftmap%ngrid, 1, zfft)

            do ist1 = 1, nst1
              do ig = 1, fftmap%ngrtot
                zfftres( ig) = zfft( ig)*zfft0( ig, ist1) 
              enddo
          
              call zfftifc( 3, fftmap%ngrid, -1, zfftres)
              !do igq = 1, ngq( iq)
              !emat( ist1, ist2, igq) = emat( ist1, ist2, igq) + zfftres( fftmap%igfft( igqig (igq, iq)))
              emat( ist1, ist2) = emat( ist1, ist2) + zfftres( fftmap%igfft( ivgig( vecgl(1), vecgl(2), vecgl(3))))
              !enddo
            enddo
          enddo
#ifdef USEOMP
!!$OMP END DO
#endif
          deallocate( zfftres, zfft)
#ifdef USEOMP
!!$OMP END PARALLEL
#endif
          
          deallocate( fftmap%igfft)
          deallocate( zfft0, zfftcf)

          
          !write(*,*) ik
          !write(*,*) vecql
          !do is = 1, nst1
          !  do ia = 1, nst2
          !    write( *, '(2I3,3x,SP,E23.16,E23.16,"i")') is, ia, emat( is, ia)
          !  end do
          !end do
          
          deallocate( igkqig, vecgkql, vecgkqc, gkqc, tpgkqc, sfacgkq, apwalm1, apwalm2, blockmt, auxmat, match_combined1, match_combined2)
          return
      end subroutine emat_genemat

      subroutine emat_destroy
          if( allocated( nlmo)) deallocate( nlmo)
          if( allocated( lmo2l)) deallocate( lmo2l)
          if( allocated( lmo2m)) deallocate( lmo2m)
          if( allocated( lmo2o)) deallocate( lmo2o)
          if( allocated( lm2l)) deallocate( lm2l)
          if( allocated( rigntaa)) deallocate( rigntaa)
          if( allocated( rigntal)) deallocate( rigntal)
          if( allocated( rigntla)) deallocate( rigntla)
          if( allocated( rigntll)) deallocate( rigntll)
          
          initialized = .false.
          return
      end subroutine emat_destroy
end module m_ematqk
