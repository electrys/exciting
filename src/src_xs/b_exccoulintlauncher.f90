! Copyright(C) 2008-2010 S. Sagmeister and C. Ambrosch-Draxl.
! This file is distributed under the terms of the GNU General Public License.
! See the file COPYING for license details.

!BOP
! !ROUTINE: b_exccoulintlauncher
! !INTERFACE:
subroutine b_exccoulintlauncher
! !USES:
  use modmpi
  use modxs, only: unitout
  use modinput, only: input
  use modbse
! !DESCRIPTION:
!   Launches the calculation of the exchange term of the Bethe-Salpeter Hamiltonian.
!
! !REVISION HISTORY:
!   Created. 2016 (Aurich)
!EOP
!BOC      

  implicit none

  logical :: fcoup, fti
  integer(4) :: iqmt, iqmti, iqmtf
  real(8) :: vqmt(3)
  character(256) :: casestring
  character(*), parameter :: thisname = "b_exccoulintlauncher"

  write(*,*) "b_exccoulintlauncher here at rank", rank

  ! Calculate RR, RA or RR and RA blocks
  casestring = input%xs%bse%blocks

  ! Also calculate coupling blocks
  if(input%xs%bse%coupling == .true.) then 
    fcoup = .true.
  else
    fcoup = .false.
    if(trim(casestring) /= "rr") then 
      ! silently set default from default of "both" to "rr"
      casestring="rr"
    end if
  end if

  ! Use time inverted anti-resonant basis
  if(input%xs%bse%ti == .true.) then 
    fti = .true.
  else
    fti = .false.
  end if

  ! Which Q points to consider 
  !   Use all
  iqmti = 1
  iqmtf = size(input%xs%qpointset%qpoint, 2)
  !   or use only one
  if(input%xs%bse%iqmt /= -1) then 
    iqmti=input%xs%bse%iqmt
    iqmtf=input%xs%bse%iqmt
  end if

  call printline(unitout, "+")
  write(unitout, '("Info(",a,"):", a)') trim(thisname),&
    & " Setting up exchange interaction matrix."
  write(unitout, '("Info(",a,"):", a, i3, a, i3)') trim(thisname),&
    & " Using momentum transfer vectors from list : ", iqmti, " to", iqmtf
  call printline(unitout, "+")

  do iqmt = iqmti, iqmtf

    vqmt(:) = input%xs%qpointset%qpoint(:, iqmt)

    if(mpiglobal%rank == 0) then
      write(unitout, *)
      call printline(unitout, "+")
      write(unitout, '("Info(",a,"):", a)') trim(thisname), &
        & "Calculating exchange interaction matrix V"
      write(unitout, '("Info(",a,"):", a, i3)') trim(thisname), &
        & " Momentum tranfer list index: iqmt=", iqmt
      write(unitout, '("Info(",a,"):", a, 3f8.3)') trim(thisname), &
        & " Momentum tranfer: vqmtl=", vqmt(1:3)
      call printline(unitout, "+")
      write(unitout,*)
    end if

    select case(trim(casestring))

      case("RR","rr")

        ! RR block
        if(mpiglobal%rank == 0) then
          write(unitout, '("Info(",a,"):&
            & Calculating RR block of V")') trim(thisname)
          write(unitout,*)
        end if
        call b_exccoulint(iqmt, .false., fti)
        call barrier(mpiglobal)

      case("RA","ra")

        ! RA block
        if(fcoup) then 
          if(mpiglobal%rank == 0) then
            call printline(unitout, "-")
            write(unitout, '("Info(",a,"):&
              & Calculating RA block of V")') trim(thisname)
          end if
          if(fti) then
            call printline(unitout, "-")
            write(unitout, '("Info(",a,"):&
              & RR = RA^{ti} no further calculation needed.")') trim(thisname)
          else
            call b_exccoulint(iqmt, .true., fti)
          end if
          call barrier(mpiglobal)
        end if
        
      case("both","BOTH")

        ! RR block
        if(mpiglobal%rank == 0) then
          write(unitout, '("Info(",a,"):&
            & Calculating RR block of V")') trim(thisname)
          write(unitout,*)
        end if
        call b_exccoulint(iqmt, .false., fti)
        call barrier(mpiglobal)

        ! RA block
        if(fcoup) then 
          if(mpiglobal%rank == 0) then
            call printline(unitout, "-")
            write(unitout, '("Info(",a,"):&
              & Calculating RA block of V")') trim(thisname)
          end if
          if(fti) then
            call printline(unitout, "-")
            write(unitout, '("Info(",a,"):&
              & RR = RA^{ti} no further calculation needed.")') trim(thisname)
          else
            call b_exccoulint(iqmt, .true., fti)
          end if
          call barrier(mpiglobal)
        end if

      case default

        write(*,'("Error(",a,"): Unrecongnized casesting:", a)') trim(thisname),&
          & trim(casestring)
        call terminate

    end select

    call printline(unitout, "+")
    write(unitout, '("Info(",a,"): Exchange interaction&
      & finished for iqmt=",i4)') trim(thisname),  iqmt
    call printline(unitout, "+")

  end do

end subroutine b_exccoulintlauncher
!EOC

