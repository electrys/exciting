module m_wannier_interpolate_eigsys
    implicit none
    contains

subroutine wannier_interpolate_eigsys( evalin, int_kset, evalout, evecout, phase)
  use modmain
  use mod_wannier
  use m_wsweight
  use m_plotmat
  use mod_kqpts
  use mod_lattice
  use mod_eigenvalue_occupancy
  use mod_eigensystem
  use mod_atoms
  use mod_muffin_tin
  use mod_lattice
  use mod_constants

  implicit none
  real(8), intent( in) :: evalin( wf_fst:wf_lst, wf_kset%nkpt)
  type( k_set), intent( in) :: int_kset
  real(8), intent( out) :: evalout( wf_fst:wf_lst, int_kset%nkpt)
  complex(8), intent( out) :: evecout( wf_fst:wf_lst, wf_fst:wf_lst, int_kset%nkpt)
  real(8), intent( out) :: phase( wf_kset%nkpt, int_kset%nkpt)
  
  integer :: nrpt, ix, iy, iz, ik, iq, ir
  complex(8) :: ftweight, z1

  real(8), allocatable :: rptl(:,:)
  complex(8), allocatable :: auxmat(:,:), ueu(:,:,:), hamilton(:,:,:)
  
  complex(8), allocatable :: p1(:,:), p2(:,:)

  !**********************************************
  ! interpolated eigenenergies and corresponding 
  ! eigenvectors in Wannier basis
  !**********************************************

  ! generate set of lattice vectors 
  nrpt = wf_kset%nkpt
  allocate( rptl( 3, nrpt))
  ir = 0
  do iz = -wf_kset%ngridk(3)/2, -wf_kset%ngridk(3)/2+wf_kset%ngridk(3)-1
    do iy = -wf_kset%ngridk(2)/2, -wf_kset%ngridk(2)/2+wf_kset%ngridk(2)-1
      do ix = -wf_kset%ngridk(1)/2, -wf_kset%ngridk(1)/2+wf_kset%ngridk(1)-1
        ir = ir + 1
        rptl( :, ir) = (/ dble( ix), dble( iy), dble( iz)/)
      end do
    end do
  end do
  
  ! calculate Hamlitonian matrix elements in Wannier representation 
  allocate( ueu( wf_fst:wf_lst, wf_fst:wf_lst, wf_kset%nkpt))
#ifdef USEOMP
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE( ik, iy, auxmat)
#endif
  allocate( auxmat( wf_fst:wf_lst, wf_fst:wf_lst))
#ifdef USEOMP
!$OMP DO
#endif
  do ik = 1, wf_kset%nkpt
    auxmat = zzero
    do iy = wf_fst, wf_lst
      auxmat( iy, :) = wf_transform( iy, :, ik)*evalin( iy, ik)
    end do
    call zgemm( 'C', 'N', wf_nst, wf_nst, wf_nst, zone, &
         wf_transform( :, :, ik), wf_nst, &
         auxmat, wf_nst, zzero, &
         ueu( :, :, ik), wf_nst)
  end do
#ifdef USEOMP
!$OMP END DO
#endif
  deallocate( auxmat)
#ifdef USEOMP
!$OMP END PARALLEL
#endif

  ! calculate phases for Fourier transform on Wigner-Seitz supercell
  allocate( p1( nrpt, wf_kset%nkpt), p2( nrpt, int_kset%nkpt))
#ifdef USEOMP
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE( ik, iq, ir)
!$OMP DO
#endif
  do ir = 1, nrpt
    do iq = 1, int_kset%nkpt
      call ws_weight( rptl( :, ir), rptl( :, ir), int_kset%vkl( :, iq), p2( ir, iq), kgrid=.true.)
    end do
    do ik = 1, wf_kset%nkpt
      call ws_weight( rptl( :, ir), rptl( :, ir), wf_kset%vkl( :, ik), p1( ir, ik), kgrid=.true.)
    end do
  end do
#ifdef USEOMP
!$OMP END DO
!$OMP END PARALLEL
#endif
  allocate( auxmat( wf_kset%nkpt, int_kset%nkpt))
  call zgemm( 'C', 'N', wf_kset%nkpt, int_kset%nkpt, nrpt, zone, &
       p1, nrpt, &
       p2, nrpt, zzero, &
       auxmat, wf_kset%nkpt)
  phase = dble( auxmat)/wf_kset%nkpt
  deallocate( p1, p2, auxmat)

  ! calculate interpolated Hamiltonian
  allocate( hamilton( wf_fst:wf_lst, wf_fst:wf_lst, int_kset%nkpt))
#ifdef USEOMP
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE( iy)
!$OMP DO
#endif
  do iy = wf_fst, wf_lst
    call zgemm( 'N', 'N', wf_nst, int_kset%nkpt, wf_kset%nkpt, zone, &
         ueu( iy, :, :), wf_nst, &
         cmplx( phase, 0, 8), wf_kset%nkpt, zzero, &
         hamilton( iy, :, :), wf_nst)
  end do
#ifdef USEOMP
!$OMP END DO
!$OMP END PARALLEL
#endif
  deallocate( ueu)

  ! diagonalize interpolated Hamiltonian
#ifdef USEOMP
!$OMP PARALLEL DEFAULT(SHARED) PRIVATE( iq)
!$OMP DO
#endif
  do iq = 1, int_kset%nkpt 
    call diaghermat( wf_nst, hamilton( :, :, iq), evalout( :, iq), evecout( :, :, iq))
  end do
#ifdef USEOMP
!$OMP END DO
!$OMP END PARALLEL
#endif
  deallocate( rptl, hamilton)

  return
end subroutine wannier_interpolate_eigsys

end module m_wannier_interpolate_eigsys
