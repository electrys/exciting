!
!
!
! Copyright (C) 2002-2005 J. K. Dewhurst, S. Sharma and C. Ambrosch-Draxl.
! This file is distributed under the terms of the GNU General Public License.
! See the file COPYING for license details.
!
!
Subroutine oepvnlk3 (ikp, vnlcv, vnlvv)
      Use modmain
      Use modinput
      Implicit None
! arguments
      Integer, Intent (In) :: ikp
      Complex (8), Intent (Out) :: vnlcv (ncrmax, natmtot, nstsv)
      Complex (8), Intent (Out) :: vnlvv (nstsv, nstsv)
! local variables
      Integer :: ngknr, ik, ist1, ist2, ist3
      Integer :: is, ia, ias, ic, m1, m2, lmax, ilm, irc
      Integer :: nrc, iq, ig, iv (3), igq0, igk
      Integer :: ilo, loindex
      Integer :: info
      Real (8) :: v (3), cfq, ta,tb
      Complex (8) zrho01, zrho02, zt1, zt2
      Integer :: nr, l, m, io1, lm2, ir, if3
! automatic arrays
      Real (8) :: zn (nspecies)
      Complex (8) sfacgq0 (natmtot)
! allocatable arrays
      Integer, Allocatable :: igkignr (:)
      Real (8), Allocatable :: vgklnr (:, :)
      Real (8), Allocatable :: vgkcnr (:, :)
      Real (8), Allocatable :: gkcnr (:)
      Real (8), Allocatable :: tpgkcnr (:, :)
      Real (8), Allocatable :: vgqc (:, :)
      Real (8), Allocatable :: tpgqc (:, :)
      Real (8), Allocatable :: gqc (:)
      Real (8), Allocatable :: jlgqr (:, :, :)
      Real (8), Allocatable :: jlgq0r (:, :, :)
      Real (8), Allocatable :: evalsvp (:)
      Real (8), Allocatable :: evalsvnr (:)
      Complex (8), Allocatable :: apwalm (:, :, :, :)
      Complex (8), Allocatable :: evecfv (:, :)
      Complex (8), Allocatable :: evecsv (:, :)
      Complex (8), Allocatable :: sfacgknr (:, :)
      Complex (8), Allocatable :: ylmgq (:, :)
      Complex (8), Allocatable :: sfacgq (:, :)
      Complex (8), Allocatable :: wfmt1 (:, :, :, :, :)
      Complex (8), Allocatable :: wfmt2 (:, :, :, :, :)
      Complex (8), Allocatable :: wfir1 (:, :, :)
      Complex (8), Allocatable :: wfir2 (:, :, :)
      Complex (8), Allocatable :: wfcr1 (:, :, :)
      Complex (8), Allocatable :: wfcr2 (:, :, :)
      Complex (8), Allocatable :: zrhomt (:, :, :)
      Complex (8), Allocatable :: zrhoir (:)
      Complex (8), Allocatable :: zvclmt (:, :, :, :)
      Complex (8), Allocatable :: zvclir (:, :)
      Complex (8), Allocatable :: zvcltp (:, :)
      Complex (8), Allocatable :: zfmt (:, :)
      Complex (8), Allocatable :: matrixl(:, :)
      Complex (8), Allocatable :: matrixm(:, :)
      Complex (8), Allocatable :: matrixm1(:, :)
      Complex (8), Allocatable :: matrixm2(:, :)
      Complex (8), Allocatable :: hfxiir(:, :)
      Complex (8), Allocatable :: hfximt(:, :, :, :)
      Complex (8), Allocatable :: zfft(:)
!      Complex (8), Allocatable :: pace(:, :)
      Complex (8), Allocatable :: fr
      Real (8), Allocatable :: cf(:,:), frre (:), frim(:), gr(:)
      Real (8), Allocatable :: xiintegralre, xiintegralim
      Complex (8), Allocatable :: xiintegral (:, :)
      Complex (8), Allocatable :: apwi(:, :)
      Complex (8), Allocatable :: matrixPC(:, :)
      type (WFType) :: wf1,wf2,prod,pot
! external functions
      Complex (8) zfinp, zfmtinp
      External zfinp, zfmtinp
! allocate local arrays
      if (.not.allocated(gntyyy)) call gengntyyy
      Allocate (igkignr(ngkmax))
      Allocate (vgklnr(3, ngkmax))
      Allocate (vgkcnr(3, ngkmax))
      Allocate (gkcnr(ngkmax))
      Allocate (tpgkcnr(2, ngkmax))
      Allocate (vgqc(3, ngvec))
      Allocate (tpgqc(2, ngvec))
      Allocate (gqc(ngvec))
      Allocate (jlgqr(0:input%groundstate%lmaxvr+input%groundstate%npsden+1, ngvec, nspecies))
      Allocate (jlgq0r(0:input%groundstate%lmaxvr, nrcmtmax, nspecies))
!      Allocate (evalsvp(nstsv))
      Allocate (evalsvnr(nstsv))
      Allocate (sfacgknr(ngkmax, natmtot))
      Allocate (apwalm(ngkmax, apwordmax, lmmaxapw, natmtot))
      Allocate (evecfv(nmatmax, nstfv))
!      Allocate (evecsv(nstsv, nstsv))
      Allocate (ylmgq(lmmaxvr, ngvec))
      Allocate (sfacgq(ngvec, natmtot))
      Allocate (wfmt1(lmmaxvr, nrcmtmax, natmtot, nspinor, nstsv))
      Allocate (wfmt2(lmmaxvr, nrcmtmax, natmtot, nspinor, nstsv))
      Allocate (wfir1(ngrtot, nspinor, nstsv))
      Allocate (wfir2(ngrtot, nspinor, nstsv))
      Allocate (wfcr1(lmmaxvr, nrcmtmax, 2))
      Allocate (wfcr2(lmmaxvr, nrcmtmax, 2))
      Allocate (zrhomt(lmmaxvr, nrcmtmax, natmtot))
      Allocate (zrhoir(ngrtot))
      Allocate (zvclmt(lmmaxvr, nrcmtmax, natmtot, nstsv))
      Allocate (zvclir(ngrtot, nstsv))
      Allocate (zvcltp(lmmaxvr, nrcmtmax))
      Allocate (zfmt(lmmaxvr, nrcmtmax))
      Allocate (matrixl(nstsv,nstsv))
      Allocate (matrixm(nstsv,nstsv))
      Allocate (matrixm1(nstsv,nstsv))
      Allocate (matrixm2(nstsv,nstsv))
      Allocate (hfxiir(ngrtot,nstsv))
      Allocate (hfximt(lmmaxvr, nrcmtmax, natmtot, nstsv))
      Allocate (zfft(ngrtot))
      if (allocated(pace)) deallocate(pace)
      Allocate (pace(nstsv,nmatmax))
      Allocate (cf (3, nrmtmax), fr, frre(nrmtmax), frim(nrmtmax), gr(nrmtmax))
      Allocate (xiintegral(nstsv,haaijSize), xiintegralre, xiintegralim)
      Allocate (apwi(haaijSize,ngkmax))
      Allocate (matrixPC(nstsv,nstfv))

      call WFInit(wf1)
      call WFInit(wf2)
      call WFInit(prod)
      call WFInit(pot)

      call genWF(ikp,wf1)
      call genWFinMT(wf1)
      call genWFonMesh(wf1)

      allocate(pot%mtrlm(lmmaxvr,nrmtmax,natmtot,1))
      allocate(pot%ir(ngrtot,1))

! factor for long-range term
      cfq = 0.5d0 * (omega/pi) ** 2
! set the nuclear charges to zero
      zn (:) = 0.d0
      zvclir (:, :) = 0.d0
      zvclmt (:, :, :, :) = 0.d0
      vnlcv (:, :, :) = 0.d0
      vnlvv (:, :) = 0.d0
! get the eigenvalues/vectors from file for input k-point
!      Call getevalsv (vkl(:, ikp), evalsvp)
      Call getevecfv (vkl(:, ikp), vgkl(:, :, :, ikp), evecfv)
!      Call getevecsv (vkl(:, ikp), evecsv)
! find the matching coefficients
      Call match (ngk(1, ikp), gkc(:, 1, ikp), tpgkc(:, :, 1, ikp), sfacgk(:, :, 1, ikp), apwalm)
! calculate the wavefunctions for all states for the input k-point
!      Call genwfsv (.False., ngk(1, ikp), igkig(:, 1, ikp), evalsvp, apwalm, evecfv, evecsv, wfmt1, wfir1)


! start loop over non-reduced k-point set
      Do ik = 1, nkptnr

! generate G+k-vectors
         Call gengpvec (vklnr(:, ik), vkcnr(:, ik), ngknr, igkignr, vgklnr, vgkcnr, gkcnr, tpgkcnr)
! get the eigenvalues/vectors from file for non-reduced k-points
         Call getevalsv (vklnr(:, ik), evalsvnr)
!         Call getevecfv (vklnr(:, ik), vgklnr, evecfv)
!         Call getevecsv (vklnr(:, ik), evecsv)
! generate the structure factors
         Call gensfacgp (ngknr, vgkcnr, ngkmax, sfacgknr)
! find the matching coefficients
!         Call match (ngknr, gkcnr, tpgkcnr, sfacgknr, apwalm)
! determine q-vector
         iv (:) = ivk (:, ikp) - ivknr (:, ik)
         iv (:) = modulo (iv(:), input%groundstate%ngridk(:))
         iq = iqmap (iv(1), iv(2), iv(3))
         v (:) = vkc (:, ikp) - vkcnr (:, ik)
         Do ig = 1, ngvec
! determine G+q vectors
            vgqc (:, ig) = vgc (:, ig) + v (:)
! G+q-vector length and (theta, phi) coordinates
            Call sphcrd (vgqc(:, ig), gqc(ig), tpgqc(:, ig))
! spherical harmonics for G+q-vector
            Call genylm (input%groundstate%lmaxvr, tpgqc(:, ig), ylmgq(:, ig))
         End Do
! structure factors for G+q
         Call gensfacgp (ngvec, vgqc, ngvec, sfacgq)
! find the shortest G+q-vector
         Call findigp0 (ngvec, gqc, igq0)
         sfacgq0 (:) = sfacgq (igq0, :)
! compute the required spherical Bessel functions
         lmax = input%groundstate%lmaxvr + input%groundstate%npsden + 1
!         Call genjlgpr (lmax, gqc, jlgqr)
         Call genjlgpr (lmax, gc, jlgqr)
         Call genjlgq0r (gqc(igq0), jlgq0r)
! calculate the wavefunctions for occupied states

         call genWF(ik,wf2)
         call genWFinMT(wf2)
         call genWFonMesh(wf2)


         Do ist3 = 1, nstsv
            If (evalsvnr(ist3) .Lt. efermi) Then
               Do ist2 = 1, nstsv
!                  If (evalsvp(ist2) .Gt. efermi) Then
! calculate the complex overlap density



!-------------------------------------------------------------------
call timesec(ta)
                     call WFprodrs(ist3,wf2,ist2,wf1,prod)
call timesec(tb)
write(*,*) 'WFprod',tb-ta
call timesec(ta)
                     Call zrhogp (gqc(igq0), jlgq0r, ylmgq(:, &
                    & igq0), sfacgq0, prod%mtrlm(:,:,:,1), prod%ir(:,1), zrho01)
call timesec(tb)
!write(*,*) 'zrhogp',tb-ta
call timesec(ta)
                     prod%ir(:,1)=prod%ir(:,1)-zrho01
                     prod%mtrlm(1,:,:,1)=prod%mtrlm(1,:,:,1)-zrho01/y00

call timesec(tb)
!write(*,*) 'remove average',tb-ta
call timesec(ta)
! calculate the Coulomb potential
                     Call zpotcoul (nrcmt, nrcmtmax, nrcmtmax, rcmt, &
                    & igq0, gqc, jlgqr, ylmgq, sfacgq, zn, prod%mtrlm(:,:,:,1), &
                    & prod%ir(:,1), pot%mtrlm(:,:,:,1), pot%ir(:,1), zrho02)
call timesec(tb)

                  Call zrhogp (gqc(igq0), jlgq0r, ylmgq(:, &
                  & igq0), sfacgq0, pot%mtrlm(:,:,:,1), pot%ir(:,1), zrho01)

                  pot%ir(:,1)=pot%ir(:,1)-zrho01
                  pot%mtrlm(1,:,:,1)=pot%mtrlm(1,:,:,1)-zrho01/y00

!write(*,*) 'zpotcoul',tb-ta
!-------------------------------------------------------------------
                        call genWFonMeshOne(pot)
                       pot%ir=conjg(pot%ir)
                       pot%mtmesh=conjg(pot%mtmesh)
                        call WFprodrs(1,pot,ist3,wf2,prod)

! ------------------------------------------------------------------
! ------------------------------------------------------------------
! ------------------------------------------------------------------
                        zvclir(:,ist2)=zvclir(:,ist2)+wkptnr(ik)*prod%ir(:,1)
                        zvclmt(:,:,:,ist2)=zvclmt(:,:,:,ist2)+wkptnr(ik)*prod%mtrlm(:,:,:,1)
! ------------------------------------------------------------------
! ------------------------------------------------------------------
! ------------------------------------------------------------------



if (.false.) then

!----------------------------------------------!
!     valence-valence-valence contribution     !
!----------------------------------------------!
                     Do ist1 = 1, nstsv

!                        If (evalsvp(ist1) .Lt. efermi) Then
! calculate the complex overlap density
call timesec(ta)
                            call WFprod(ist3,wf2,ist1,wf1,prod)
call timesec(tb)
!write(*,*) 'WFprod',tb-ta
call timesec(ta)
                            Call zrhogp (gqc(igq0), jlgq0r, ylmgq(:, &
                           & igq0), sfacgq0, prod%mtrlm(:,:,:,1), prod%ir(:,1), zrho01)
call timesec(tb)
!write(*,*) 'zrhogp',tb-ta
call timesec(ta)
                            prod%ir(:,1)=prod%ir(:,1)-zrho01
                            prod%mtrlm(1,:,:,1)=prod%mtrlm(1,:,:,1)-zrho01/y00
call timesec(tb)
!write(*,*) 'remove average',tb-ta
call timesec(ta)
                           zt1 = zfinp (.True., prod%mtrlm(:,:,:,1), zvclmt, prod%ir(:,1), zvclir)
call timesec(tb)
!write(*,*) 'zfinp',tb-ta

!stop
!-------------------------------------------------------------------
! compute the density coefficient of the smallest G+q-vector
                           zt2 = cfq * wiq2 (iq) * &
                          & (conjg(zrho01)*zrho02)
                           zt2 =0d0
                           vnlvv (ist1, ist2) = vnlvv (ist1, ist2) - &
                          & (wkptnr(ik)*zt1+zt2)
!                        End If
                     End Do
end if



! end loop over ist2
!                  End If
               End Do
! end loop over ist3
            End If
         End Do
! end loop over non-reduced k-point set
      End Do


Do ist1 = 1, nstsv
      Do ist3 = 1, nstsv
            zt1 = zfinp (.True., wf1%mtrlm(:,:,:,ist1),zvclmt(:,:,:,ist3), wf1%ir(:,ist1), zvclir(:,ist3))
            vnlvv (ist1, ist3) = vnlvv (ist1, ist3) - zt1
      End Do
End Do

! -- Adaptively Compressed Exchange Operator starts --

matrixl = -vnlvv ! create copy

! Remove upper triangular part
Do ist1 = 2, nstsv
    matrixl(ist1-1,ist1:)=0
End Do

Call zpotrf('L',nstsv,matrixl,nstsv,info) ! Computes the Cholesky factorization
If (info==0) Then
    Call ztrtri('L','N',nstsv,matrixl,nstsv,info) ! Invert L
    If (.not.(info==0)) Then
        Write (*, *) 'matrixl is not invertable! Info=',info
        stop
    End If
Else
    Write (*, *) 'vnlvv is not negative definite! Info=',info
    stop
End If

Call zgemm('N','C',ngrtot,nstsv,nstsv,(1.0D0,0.0),zvclir,ngrtot,matrixl,nstsv,(0.0D0,0.0),hfxiir,ngrtot) ! compute IR part of ACEO

Do ilm = 1, lmmaxvr
    Do irc = 1, nrcmtmax
        Call zgemm('N','C', natmtot, nstsv, nstsv, (1.0D0,0.0), zvclmt(ilm,irc,:,:), natmtot, matrixl, nstsv, (0.0D0,0.0), hfximt(ilm,irc,:,:), natmtot) ! compute MT part of ACEO
    End Do
End Do

! -- calculating IR part of <xi|phi>=FT(xi_ir*theta)

pace=0
Do ist1 =1, nstsv
    zfft=conjg(hfxiir(:,ist1))*cfunir
    Call zfftifc (3, ngrid,-1,zfft)
    Do igk=1,ngk(1,ikp)
        pace(ist1,igk)=zfft(igfft(igkig(igk,1,ikp)))*sqrt(Omega)
    End Do
End Do

! -- calculating MT part of <xi|phi>
if3=0 ! jāparliek uz 356 aiz ias
loindex=0
Do is = 1, nspecies
    nr = nrmt (is)
    Do ia = 1, natoms (is)
        ias = idxas (ia, is)
        
        Do l = 0, input%groundstate%lmaxmat
            Do m = -l, l
                Do io1 = 1, apword (l, is)
                    lm2 = idxlm (l, m)
                    ! m2 = mfromlm(lm2)
                    ! l2 = lfromlm(lm2)
                    if3=if3+1
                    apwi(if3,:)=apwalm(1:ngk(1,ikp), io1, lm2, ias)
                    Do ist2 = 1, nstsv
                        Do ir = 1, nr   ! pārbaudīt nr
                            fr=apwfr(ir,1,io1,l,ias)*conjg(hfximt(lm2,ir,ias,ist2)) *spr(ir, is) ** 2 ! r2(ir)=spr(ir, is) ** 2
                            frre (ir)=dble(fr)
                            frim (ir)=aimag(fr)
                        End Do
                        Call fderiv (-1, nr, spr(:, is), frre, gr, cf)  ! cf ir darba mainīgais
                        xiintegralre=gr (nr) ! real part
                        Call fderiv (-1, nr, spr(:, is), frim, gr, cf)  ! cf ir darba mainīgais
                        xiintegralim=gr (nr) ! imag part
                        xiintegral (ist2,if3)=dcmplx(xiintegralre,xiintegralim) ! nāk klāt is un ia
                        !write(*,*) gr(1), gr(nr), gr(150), gr(151)
                    End Do
                End Do
            End Do
        End Do
        Do ilo= 1, nlorb(is)
            l = lorbl (ilo, is)
            Do m = -l, l
                    lm2 = idxlm (l, m)
                    loindex=loindex+1
                    Do ist2 = 1, nstsv
                        Do ir = 1, nr   ! pārbaudīt nr
                            fr=lofr(ir,1,ilo,ias)*conjg(hfximt(lm2,ir,ias,ist2)) *spr(ir, is) ** 2 ! r2(ir)=spr(ir, is) ** 2
                            frre (ir)=dble(fr)
                            frim (ir)=aimag(fr)
                        End Do
                        Call fderiv (-1, nr, spr(:, is), frre, gr, cf)  ! cf ir darba mainīgais
                        xiintegralre=gr (nr) ! real part
                        Call fderiv (-1, nr, spr(:, is), frim, gr, cf)  ! cf ir darba mainīgais
                        xiintegralim=gr (nr) ! imag part
                        pace (ist2,loindex+ngk(1,ikp))= dcmplx(xiintegralre,xiintegralim) ! citu mainīgo un jāsasummē
                        !write(*,*) gr(1), gr(nr), gr(150), gr(151)
                    End Do                
            End Do             
        End Do ! LO
    End Do
End Do
!write(*,*) if3, haaijSize
!write(*,*) nr, nrmtmax
!write(*,*) ngkmax, ngrtot, nmatmax, natmtot
!write(*,*) nstsv, nstfv
!write(*,*) gr(:)
!write(*,*) fr(:)
!      do ist1 = 1, nstsv
!        write(*,'(12E13.5)') dble(hxiaintegrals(ist1,:))
!      end do

Call zgemm('N', 'N', nstsv, ngkmax, haaijSize, dcmplx(1.0D0,0.0), xiintegral, nstsv, apwi, haaijSize, dcmplx(1.0D0,0.0), pace, nstsv) ! pace= paceMT+paceIR = xiintegral*apwi+ pace

! haaintegrals(apwordmax, 0:input%groundstate%lmaxmat,lmmaxvr,natmtot,nstsv)
! hfximt(lmmaxvr, nrcmtmax, natmtot, nstsv)=hfximt(lm2,ir,ias,ist)
! zvclmt(lmmaxvr, nrcmtmax, natmtot, nstsv)
! apwalm(ngkmax, apwordmax, lmmaxapw, natmtot)
! hxiaintegrals(lmmaxvr,natmtot,nstsv,apwordmax, 0:input%groundstate%lmaxmat)
! evecfv(nmatmax, nstfv)
! hxiaintegrals(nstsv,haaijSize)
! apwi(haaijSize,ngkmax)
! pace(nstsv,ngkmax) ! nmatmax
! matrixPC(nstsv,nstfv)

! -- calculating LO part of <xi|phi>

!! -- Adaptively Compressed Exchange Operator test
! test pace
if (.false.) then
    Call zgemm('N', 'N', nstsv, nstfv, nmatmax, dcmplx(1.0D0,0.0), pace, nstsv, evecfv, nmatmax, dcmplx(0.0D0,0.0), matrixPC, nstsv) ! matrixPC=pace*evecfv
    Call zgemm('C', 'N', nstfv, nstfv, nstsv, dcmplx(1.0D0,0.0), matrixPC, nstfv, matrixPC, nstsv, dcmplx(0.0D0,0.0), matrixm2, nstfv) ! matrixM2=matrixPC^+ *matrixPC
endif

! test hfxi
if (.false.) then
    Do ist1 = 1, nstsv
        Do ist2 = 1, nstsv
            matrixm1(ist1,ist2) = zfinp(.True., wf1%mtrlm(:,:,:,ist1), hfximt(:,:,:,ist2), wf1%ir(:,ist1), hfxiir(:,ist2))
        End Do
    End Do
    Call zgemm('N','C', nstsv, nstsv, nstsv, (-1.0D0,0.0), matrixm1, nstsv, matrixm1, nstsv, (0.0D0,0.0), matrixm, nstsv)
endif

! matrix print compare
if (.false.) then
    write(*,*) 'matrixm2 real (pace)'
      do ist1 = 1, nstsv
        write(*,'(12E13.5)') dble(matrixm2(ist1,:))
      end do

    write(*,*) 'matrixm real (hfxi)'
      do ist1 = 1, nstsv
        write(*,'(12E13.5)') dble(matrixm(ist1,:))
      end do

    write(*,*) 'matrixm2 imag (pace)'
      do ist1 = 1, nstsv
        write(*,'(12E13.5)') dimag(matrixm2(ist1,:))
      end do

    write(*,*) 'matrixm imag (hfxi)'
      do ist1 = 1, nstsv
        write(*,'(12E13.5)') dimag(matrixm(ist1,:))
      end do
      stop
endif


!-- Adaptively Compressed Exchange Operator ends --


      Deallocate (igkignr, vgklnr, vgkcnr, gkcnr, tpgkcnr)
      Deallocate (vgqc, tpgqc, gqc, jlgqr, jlgq0r)
!      Deallocate (evalsvp)
      Deallocate (evalsvnr)
      Deallocate (evecfv) !, evecsv)
      Deallocate (apwalm)
      Deallocate (sfacgknr, ylmgq, sfacgq)
      Deallocate (wfmt1, wfmt2, wfir1, wfir2, wfcr1, wfcr2)
      Deallocate (zrhomt, zrhoir, zvclmt, zvclir, zvcltp, zfmt)
      Deallocate (matrixl, matrixm, matrixm1, zfft)
      call WFRelease(wf1)
      call WFRelease(wf2)
      call WFRelease(prod)
write(*,*) 'WFRelease done'
      deallocate(gntyyy)
      Return
End Subroutine
!EOC
