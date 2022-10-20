!
!
!
! Copyright (C) 2002-2005 J. K. Dewhurst, S. Sharma and C. Ambrosch-Draxl.
! This file is distributed under the terms of the GNU General Public License.
! See the file COPYING for license details.
!
!BOP
! !ROUTINE: mossbauer
! !INTERFACE:
!
!
Subroutine mossbauer
! !USES:
      Use modinput
      Use modmain
      Use Fox_wxml
      use constants, only: fourpi, pi
      use modinteg
! !DESCRIPTION:
!   Computes the contact charge density and contact magnetic hyperfine field for
!   each atom and outputs the data to the file {\tt MOSSBAUER.OUT}. The nuclear
!   radius used for the contact quantities is approximated by the empirical
!   formula $R_{\rm N}=1.25 Z^{1/3}$ fm, where $Z$ is the atomic number.
!
! !REVISION HISTORY:
!   Created May 2004 (JKD)
!   xml file added 2019 (BM)      
!EOP
!BOC
      Implicit None
! local variables
      Integer :: is, ia, ias, ir, nr
      Type (xmlf_t), Save :: xf
! nuclear radius constant in Bohr
      Real (8), Parameter :: r0 = 1.25d-15 / 0.52917720859d-10
      Real (8) :: rn, vn, rho0, b, t1
! allocatable arrays
      Real (8), Allocatable :: fr (:)
      Real (8), Allocatable :: gr (:)
      Real (8), Allocatable :: cf (:, :)
! initialise universal variables
      Call init0
! read density and potentials from file
      Call readstate
! allocate local arrays
      Allocate (fr(nrmtmax))
      Allocate (gr(nrmtmax))
      Allocate (cf(3, nrmtmax))
      Open (50, File='MOSSBAUER.OUT', Action='WRITE', Form='FORMATTED')
      Call xml_OpenFile ("mossbauer.xml", xf, replace=.True., pretty_print=.True.)
      Call xml_newElement (xf, "mossbauer")
      Do is = 1, nspecies
      Call xml_NewElement (xf, "species")
      Call xml_AddAttribute (xf, "n", is)
      Call xml_AddAttribute (xf, "chemicalSymbol", trim(input%structure%speciesarray(is)%species%chemicalSymbol))
!--------------------------------!
!     contact charge density     !
!--------------------------------!
! approximate nuclear radius : r0*A^(1/3)
         rn = r0 * Abs (spzn(is)) ** (1.d0/3.d0)
         Do ir = 1, nrmt (is)
            If (spr(ir, is) .Gt. rn) Go To 10
         End Do
         Write (*,*)
         Write (*, '("Error(mossbauer): nuclear radius too large : ", G&
        &18.10)') rn
         
         Write (*, '(" for species ", I4)') is
         Write (*,*)
         Call xml_AddCharacters (xf, "Error(mossbauer): nuclear radius too large.")
         Call xml_EndElement (xf, "species")
         Call xml_EndElement (xf, "mossbauer")
         Call xml_Close (xf)
         Stop
10       Continue
         nr = ir
         rn = spr (nr, is)
! nuclear volume
         vn = (4.d0/3.d0) * pi * rn ** 3
         Do ia = 1, natoms (is)
            ias = idxas (ia, is)
!--------------------------------!
!     contact charge density     !
!--------------------------------!
            fr (1:nr) = rhomt (1, 1:nr, ias) * y00
            Do ir = 1, nr
               fr (ir) = (fourpi*spr(ir, is)**2) * fr (ir)
            End Do
#ifdef integlib
            Call integ_v_atom ( nr, is, fr, t1)
#else
            Call fderiv (-1, nr, spr(:, is), fr, gr, cf)
            t1=gr (nr)
#endif
            rho0 = t1 / vn
            Write (50,*)
            Write (50, '("Species : ", I4, " (", A, "), atom : ", I4)') &
           & is, trim &
           & (input%structure%speciesarray(is)%species%chemicalSymbol), &
           & ia
            Write (50, '(" approximate nuclear radius : ", G18.10)') rn
            Write (50, '(" number of mesh points to nuclear radius : ",&
           & I6)') nr
            Write (50, '(" contact charge density : ", G18.10)') rho0
            Call xml_NewElement (xf, "atom")
            Call xml_AddAttribute (xf, "n", ia)
            Call xml_AddAttribute (xf, "approxNucRad", rn)
            Call xml_AddAttribute (xf, "numOfMeshPtsToNucRad", nr)
            Call xml_AddAttribute (xf, "contactChargeDensity", rho0)
!------------------------------------------!
!     contact magnetic hyperfine field     !
!------------------------------------------!
            If (associated(input%groundstate%spin)) Then
               Do ir = 1, nr
                  If (ncmag) Then
! non-collinear
                     t1 = Sqrt (magmt(1, ir, ias, 1)**2+magmt(1, ir, &
                    & ias, 2)**2+magmt(1, ir, ias, 3)**2)
                  Else
! collinear
                     t1 = magmt (1, ir, ias, 1)
                  End If
                  fr (ir) = t1 * y00 * fourpi * spr (ir, is) ** 2
               End Do
#ifdef integlib
               Call integ_v_atom ( nr, is, fr, t1)
#else
               Call fderiv (-1, nr, spr(:, is), fr, gr, cf)
               t1=gr (nr)
#endif
               b = t1 / vn
               Write (50, '(" contact magnetic hyperfine field (mu_B) :&
              & ", G18.10)') b
               Call xml_AddAttribute (xf, "contactMagHyperfineField", b)
            End If
            Call xml_EndElement (xf, "atom")
         End Do
         Call xml_EndElement (xf, "species")
      End Do
      Call xml_EndElement (xf, "mossbauer")
      Call xml_Close (xf)

      Close (50)
      Write (*,*)
      Write (*, '("Info(mossbauer):")')
      Write (*, '(" Mossbauer parameters written to MOSSBAUER.OUT")')
      Write (*,*)
      Deallocate (fr, gr, cf)
      Return
End Subroutine
!EOC
