!
!
!
! Copyright (C) 2002-2005 J. K. Dewhurst, S. Sharma and C. Ambrosch-Draxl.
! This file is distributed under the terms of the GNU General Public License.
! See the file COPYING for license details.
!
!BOP
! !ROUTINE: seceqnfv
! !INTERFACE:
!
!
Subroutine seceqnfv(ispn, ik, nmatp, ngp, igpig, vgpc, apwalm, evalfv, evecfv)
  ! !USES:
      Use modinput
      Use mod_Gkvector, only: ngkmax
      Use mod_APW_LO, only: apwordmax
      Use mod_atoms, only: natmtot
      Use mod_muffin_tin, only: lmmaxapw
      Use mod_eigensystem, only: nmatmax, h1on, h1aa, h1loa, h1lolo, mt_hscf, MTRedirect
      Use mod_eigenvalue_occupancy, only: nstfv
      Use mod_potential_and_density, only: ex_coef
      Use modfvsystem
      Use mod_hybrids,               only: vnlmat
      use mod_misc,                  only: task
      use m_plotmat
      Use constants, only: zzero, zone
!
  ! !INPUT/OUTPUT PARAMETERS:
  !   nmatp  : order of overlap and Hamiltonian matrices (in,integer)
  !   ngp    : number of G+k-vectors for augmented plane waves (in,integer)
  !   igpig  : index from G+k-vectors to G-vectors (in,integer(ngkmax))
  !   vgpc   : G+k-vectors in Cartesian coordinates (in,real(3,ngkmax))
  !   apwalm : APW matching coefficients
  !            (in,complex(ngkmax,apwordmax,lmmaxapw,natmtot))
  !   evalfv : first-variational eigenvalues (out,real(nstfv))
  !   evecfv : first-variational eigenvectors (out,complex(nmatmax,nstfv))
  ! !DESCRIPTION:
  !   Solves the secular equation,
  !   $$ (H-\epsilon O)b=0, $$
  !   for the all the first-variational states of the input $k$-point.
  !
  ! !REVISION HISTORY:
  !   Created March 2004 (JKD)
  !   Revised Aug 2020 (Ronaldo)
  !EOP
  !BOC
      Implicit None
  ! arguments
      Integer, Intent (In) :: ispn
      Integer, Intent (In) :: ik
      Integer, Intent (In) :: nmatp
      Integer, Intent (In) :: ngp
      Integer, Intent (In) :: igpig (ngkmax)
      Real (8), Intent (In) :: vgpc (3, ngkmax)
      Complex (8), Intent (In) :: apwalm (ngkmax, apwordmax, lmmaxapw, &
     & natmtot)
      Real (8), Intent (Out) :: evalfv (nstfv)
      Complex (8), Intent (Out) :: evecfv (nmatmax, nstfv)
  ! local variables
      Type (evsystem) :: system
      Logical :: packed
      Integer :: ist
      Complex (8), allocatable :: zm(:,:),zm2(:,:)
      !character( len=64) :: fname

  !----------------------------------------!
  !     Hamiltonian and overlap set up     !
  !----------------------------------------!

      packed = input%groundstate%solver%packedmatrixstorage

      Call newsystem (system, packed, nmatp)
      h1on=(input%groundstate%ValenceRelativity.eq.'iora*')
      call MTRedirect(mt_hscf%main,mt_hscf%spinless)
      Call hamiltonsetup (system, ngp, apwalm, igpig, vgpc)
      Call overlapsetup (system, ngp, apwalm, igpig, vgpc)

  !------------------------------------------------------------------------!
  !   If Hybrid potential is used apply the non-local exchange potential !
  !------------------------------------------------------------------------!
      if (task == 7) then
          system%hamilton%za(:,:) = system%hamilton%za(:,:) + &
                                    ex_coef*vnlmat(1:nmatp,1:nmatp,ik)
      end if

  !------------------------------------!
  !     solve the secular equation     !
  !------------------------------------!
      Call solvewithlapack(system,nstfv,evecfv,evalfv)

      if (task == 7) call kinetic_energy(ik,evecfv,apwalm,ngp,vgpc,igpig)

if (input%groundstate%ValenceRelativity.eq.'iora*') then
! normalise large components
      Call newsystem (system, packed, nmatp)
      h1aa=0d0
      h1loa=0d0
      h1lolo=0d0
      h1on=.false.
!      Call hamiltonandoverlapsetup (system, ngp, apwalm, igpig, vgpc)
      Call overlapsetup (system, ngp, apwalm, igpig, vgpc)
      call olprad
      allocate(zm(nmatp,nstfv))
      allocate(zm2(nstfv,nstfv))


      call zgemm('N', &           ! TRANSA = 'C'  op( A ) = A**H.
                 'N', &           ! TRANSB = 'N'  op( B ) = B.
                  nmatp, &          ! M ... rows of op( A ) = rows of C
                  nstfv, &           ! N ... cols of op( B ) = cols of C
                  nmatp, &          ! K ... cols of op( A ) = rows of op( B )
                  zone, &          ! alpha
                  system%overlap%za, &           ! A
                  nmatp,&           ! LDA ... leading dimension of A
                  evecfv, &           ! B
                  nmatmax, &          ! LDB ... leading dimension of B
                  zzero, &          ! beta
                  zm, &  ! C
                  nmatp &      ! LDC ... leading dimension of C
                  )
      call zgemm('C', &           ! TRANSA = 'C'  op( A ) = A**H.
                 'N', &           ! TRANSB = 'N'  op( B ) = B.
                  nstfv, &          ! M ... rows of op( A ) = rows of C
                  nstfv, &           ! N ... cols of op( B ) = cols of C
                  nmatp, &          ! K ... cols of op( A ) = rows of op( B )
                  zone, &          ! alpha
                  evecfv, &           ! A
                  nmatmax,&           ! LDA ... leading dimension of A
                  zm, &           ! B
                  nmatp, &          ! LDB ... leading dimension of B
                  zzero, &          ! beta
                  zm2, &  ! C
                  nstfv &      ! LDC ... leading dimension of C
                  )

!     write(*,*) zm2(1:2,1:2)
!      do ist=1,nstfv
!        write(*,*) zm2(ist,ist)
!      enddo
!      write(*,*)
      do ist=1,nstfv
        evecfv(:,ist)=evecfv(:,ist)/sqrt(abs(zm2(ist,ist)))
      enddo
      deallocate(zm,zm2)
      Call deletesystem (system)
endif

End Subroutine seceqnfv
!EOC
