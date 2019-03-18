!
!BOP
! !ROUTINE: hybrids
! !INTERFACE:
!
Subroutine hybrids
! !USES:
    Use modinput
    Use modmain
    Use modmpi
    Use scl_xml_out_Module
    Use mod_hybrids
!
! !DESCRIPTION:
!   Main routine for Hartree-Fock based hybrid functionals.
!
! !REVISION HISTORY:
!   Created September 2013 (DIN)
!   Modified October 2013
!   Modified Februar 2014
!EOP
!BOC
    Implicit None

    integer :: ik, Recl
    real(8) :: et
! time measurements
    Real(8) :: timetot, ts0, ts1, tsg0, tsg1, tin1, tin0, time_hyb
    character*(77) :: string
 
    ! Charge distance
    Real (8), Allocatable :: rhomtref(:,:,:) ! muffin-tin charge density (reference)
    Real (8), Allocatable :: rhoirref(:)     ! interstitial real-space charge density (reference)
    integer :: xctype_(3)    
    logical :: exist

!! TIME - Initialisation segment
    call timesec(tsg0)
    call timesec(ts0)

! Tetrahedron method
    input%groundstate%stypenumber = -1

! Initialise global variables
    Call timesec (tin0)
    Call init0
    Call timesec (tin1)
    time_init0=tin1-tin0
    Call timesec (tin0)
    Call init1
    Call timesec (tin1)
    time_init1=tin1-tin0
     
! require forces for structural optimisation
    If ((task==2).or.(task==3)) input%groundstate%tforce = .True.    
    
!-------------------
! print info
!-------------------

    if (rank==0) then
! open INFO.OUT file
        open(60, File='INFO'//trim(filext), Action='WRITE', Form='FORMATTED')
! write out general information to INFO.OUT
        call writeinfo(60)
! write the real and reciprocal lattice vectors to file
        Call writelat
! write interatomic distances to file
        Call writeiad (.False.)
! write symmetry matrices to file
        Call writesym
#ifdef XS
! write relation to inverse symmetries
        Call writesymi
! write advanced information on symmetry group
        Call writesym2
! write out symmetrization matrix for rank 2 tensors
        Call writesymt2
#endif
! output the k-point set to file
        Call writekpts
! write lattice vectors and atomic positions to file
        Call writegeometryxml(.False.)

!___________________
! Open support files

! open TOTENERGY.OUT
        Open (61, File='TOTENERGY'//trim(filext), Action='WRITE', Form='FORMATTED')

! open RMSDVEFF.OUT
        Open (65, File='RMSDVEFF'//trim(filext), Action='WRITE', Form='FORMATTED')

! open MOMENT.OUT if required
        If (associated(input%groundstate%spin)) then
            open (63, file='MOMENT'//trim(filext), action='WRITE', form='FORMATTED')
        end if

    end if ! rank

    Call timesec (ts1)
    timeinit = timeinit+ts1-ts0
!! TIME - End of initialisation segment

    if (rank==0) then
        write(string,'("Hybrids module started")') 
        call printbox(60,"*",string)
        call flushifc(60)
    end if

!---------------------------------------
! initialise HF related input parameters
!---------------------------------------
    time_hyb = 0.d0
    call timesec(ts0)
    call init_hybrids
    call timesec(ts1)
    time_hyb = time_hyb+ts1-ts0
    ihyb=0    
!------------------------------------------!
! begin the (external) self-consistent loop
!------------------------------------------!

    ! reference density
    If (allocated(rhomtref)) deallocate(rhomtref)
    Allocate(rhomtref(lmmaxvr,nrmtmax,natmtot))
    If (allocated(rhoirref)) deallocate(rhoirref)
    Allocate (rhoirref(ngrtot))

    !----------------------
    ! restart is requested
    !----------------------
    write(*,*) "Ceci beforehere"
    if (task==1) then
    write(*,*) "Ceci beforehere1"

      inquire(File='VNLMAT.OUT', Exist=exist)  !do we need this??? I do not think so

      if (exist) then
      
        ! restart previous (unfinished) hybrid run

        call timesec(ts0)
        !______________________________
        ! step 1: read local potential
        string = filext
        filext = '_PBE.OUT'
        call readstate
        ! generate radial functions
        call gencore
        call linengy
        call genapwfr
        call genlofr
        call olprad
!        call hmlint  !ADDED NOW
!        Call genmeffig !ADDED NOW
!        call energykncr   !THIS SHOULD STILL BE TESTED AFTER IN THE RESTART FOR THE KINETIC ENERGY
!        if (input%groundstate%Hybrid%updateRadial) call updateradial
        ex_coef = 0.d0
        ec_coef = 1.d0
        ! for Libxc use PBE from Libxc
        if (xctype(1)==100) then
          xctype_ = xctype
          xctype = (/100, 101, 130/)
        end if
        call scf_cycle(1)
        call timesec(ts0)
        call init_product_basis
        call timesec(ts1)
     if (rank==0) then
        write(60,*)
        write(60, '(" CPU time for init_product_basis (seconds)",T45 ": ", F12.2)') ts1-ts0
     end if
        
        !______________________________
        ! step 2: read density and (local) potential from previous run
        filext = string
        call readstate
        !______________________________
        ! step 3: read nonlocal potential matrix
        call getvnlmat
         do ik = 1, nkpt
           write(*,*) "readvnlmat ik=", ik, sum(vnlmat(:,:,ik))
         end do
        call timesec(ts1)

        if (rank==0) then
          call write_cputime(60,ts1-ts0, 'Restart')
          write(60,*)
        end if    
        time_hyb = time_hyb+ts1-ts0
        !If the calculation stops during the internal scf we nned tofinish the scf
        task = 7 ! <-- hybrids switcher
        if (xctype(1) == 100) then
           xctype = xctype_
        end if
        ex_coef = input%groundstate%Hybrid%excoeff
        ec_coef = input%groundstate%Hybrid%eccoeff
        call scf_cycle(-1)
        !rhomtref(:,:,:) = rhomt(:,:,:)
        !rhoirref(:) = rhoir(:)
        If (rank==0) Then
            write(string,'("Hybrids restart")')
            call printbox(60,"+",string)
            Call flushifc(60)
            call writeengy(60)
            write(60,*)
            write(60,'(" DOS at Fermi energy (states/Ha/cell)",T45 ": ", F18.8)') fermidos
            call writechg(60,input%groundstate%outputlevelnumber)
            if (fermidos<1.0d-4) call printbandgap(60)
            call flushifc(60)
        end if

        !!!WE SHOULD ADD A WAY TO EXIT IF THE CONVERGENCE IS REACHED, BUT BECAUSE THE CODE STOPPED AT THE LAST HYBRID  STEP IN THE SCF


     else
    write(*,*) "Ceci beforehere2"
        ! restart previous (unfinished) hybrid run, which have been interupt during the initial SCF with PBE
        string = filext
        filext = '_PBE.OUT'
        call readstate
        filext = string
        ! generate radial functions
        call gencore
        call linengy
        call genapwfr
        call genlofr
        call olprad
        If (rank==0) Then
            write(string,'("Restart SCF with PBE")')
            call printbox(60,"+",string)
            Call flushifc(60)
        End If
        ! perform normal DFT self-consistent run
        ex_coef = 0.d0
        ec_coef = 1.d0
        ! for Libxc use PBE from Libxc
        if (xctype(1)==100) then
          xctype_ = xctype
          xctype = (/100, 101, 130/)
        end if
        call scf_cycle(-1)
        if (rank == 0) then
          call writeengy(60)
          write(60,*)
          write(60,'(" DOS at Fermi energy (states/Ha/cell)",T45 ": ", F18.8)') fermidos
          call writechg(60,input%groundstate%outputlevelnumber)
          if (fermidos<1.0d-4) call printbandgap(60)
          call flushifc(60)
        end if
        ! update radial functions
        if (input%groundstate%Hybrid%updateRadial) call updateradial
      end if

    else
!If it is not restart initaial SCF
!--------------------------------------------------
! Preliminar SCF with PBE
!--------------------------------------------------
      write(*,*) "Ceci here"
      If (rank==0) Then
              write(string,'("Preliminar SCF with PBE")')
              call printbox(60,"+",string)
              Call flushifc(60)
      End If
      ! perform normal DFT self-consistent run
      ex_coef = 0.d0
      ec_coef = 1.d0
      ! for Libxc use PBE from Libxc
      if (xctype(1)==100) then
         xctype_ = xctype
         xctype = (/100, 101, 130/)
      end if
      write(*,*) "Ceci here1"
      call scf_cycle(-1)
      write(*,*) "Ceci here2"
      if (rank == 0) then
         call writeengy(60)
         write(60,*)
         write(60,'(" DOS at Fermi energy (states/Ha/cell)",T45 ": ", F18.8)') fermidos
         call writechg(60,input%groundstate%outputlevelnumber)
         if (fermidos<1.0d-4) call printbandgap(60)
         call flushifc(60)
      end if
      ! update radial functions
      !if (input%groundstate%Hybrid%updateRadial) call updateradial
     call timesec(ts0)
     call init_product_basis
     call timesec(ts1)
     if (rank==0) then
        write(60,*)
        write(60, '(" CPU time for init_product_basis (seconds)",T45 ": ", F12.2)') ts1-ts0
     end if
    endif
!--------------------------------------------------
! Inizialize mixed product basis
!--------------------------------------------------
     if (rank==0) then
        write(60,*)
        write(60, '(" CPU time for init_product_basis (seconds)",T45 ": ", F12.2)') ts1-ts0
     end if
!--------------------------------------------------
! Hybrid functionals settings
!--------------------------------------------------
      task = 7 ! <-- hybrids switcher
      ! restore settings for hybrid functional
      ex_coef = input%groundstate%Hybrid%excoeff
      ec_coef = input%groundstate%Hybrid%eccoeff
      if (xctype(1) == 100) then
          xctype = xctype_
      end if
      ! settings for convergence and mixing
      input%groundstate%mixerswitch = 1
      input%groundstate%scfconv = 'charge'


!--------------------------------------------------
! Main loop
!--------------------------------------------------
    do ihyb = 1, input%groundstate%Hybrid%maxscl

    
       rhomtref(:,:,:) = rhomt(:,:,:)
       rhoirref(:) = rhoir(:)
       If (rank==0) Then
            write(string,'("Hybrids iteration number : ", I4)') ihyb
            call printbox(60,"+",string)
            Call flushifc(60)
        End If
        
!-----------------------------------
! Calculate the non-local potential
!-----------------------------------
       if (rank==0) then
          write(60,*)
       end if
       !------------------------------------------
       call timesec(ts0)
       call calc_vxnl
       if (rank==0) write(fgw,*) 'vxnl=', sum(vxnl)
       call timesec(ts1)
       if (rank==0) then
           write(60, '(" CPU time for vxnl (seconds)",T45 ": ", F12.2)') ts1-ts0
       end if
       !------------------------------------------
       call timesec(ts0)
       write(*,*) "before vnlmat"
       call calc_vnlmat
       write(*,*) "after vnlmat"
       if (rank==0) write(fgw,*) 'vnlmat=', sum(vnlmat)
       call timesec(ts1)
       if (rank==0) then
           write(60, '(" CPU time for vnlmat (seconds)",T45 ": ", F12.2)') ts1-ts0
           write(60,*)
       end if
       !------------------------------------------
       if (input%groundstate%Hybrid%savepotential) call writevnlmat
       write(*,*) input%groundstate%Hybrid%savepotential
        !do ik = 1, nkpt
        !  write(*,*) "writevnlmat ik=", ik, sum(vnlmat(:,:,ik))
        !end do
       time_hyb = time_hyb+ts1-ts0
       
        
! output the current total time
!        timetot = timeinit + timemat + timefv + timesv + timerho  &
!        &       + timepot + timefor + timeio + timemt + timemixer &
!        &       + time_hyb
!            
!        if (rank==0) then
!            write(60, '(" Wall time (seconds)",T45 ": ", F12.2)') timetot
!        end if
       call scf_cycle(-1)
       if (rank == 0) then
           call writeengy(60)
           write(60,*)
           write(60,'(" DOS at Fermi energy (states/Ha/cell)",T45 ": ", F18.8)') fermidos
           call writechg(60,input%groundstate%outputlevelnumber)
           if (fermidos<1.0d-4) call printbandgap(60)
           call flushifc(60)
       end if
        
!---------------------------
! Convergence check
!---------------------------
       call chgdist(rhomtref,rhoirref)
       if (rank==0) Then
         write(60,*)
         write(60,'(" Charge distance                   (target) : ",G13.6," (",G13.6,")")') &
           &     chgdst, input%groundstate%epschg
       end if
       if (chgdst .lt. input%groundstate%epschg) then
           if (rank==0) Then
               write(string,'("Convergence target is reached")')
               call printbox(60,"+",string)
               Call flushifc(60)
            end If
            exit ! exit ihyb-loop
        end if
        et = engytot

!---------------------------
! Output information: loop stoped becuase reached maximum scf step 
!---------------------------
        If (ihyb == input%groundstate%Hybrid%maxscl) Then
            If (rank==0) Then
                write(string,'("Reached hybrids self-consistent loops maximum : ", I4)') &
               &  input%groundstate%Hybrid%maxscl
                call printbox(60,"+",string)
                call warning('Warning(hybrids): Reached self-consistent loops maximum')
                Call flushifc(60)
            End If
        End If
 
    end do ! ihyb

    if (rank==0) then
        write(string,'("Hybrids module stopped")') 
        call printbox(60,"+",string)
        call flushifc(60)
    end if

!-------------------------------------!
!   output timing information
!-------------------------------------!
!! TIME - Fifth IO segment
    call timesec(ts0)
    if (rank==0) then

!____________________
! Close support files

! close the TOTENERGY.OUT file
        close(61)
! close the RMSDVEFF.OUT file
        close(65)
! close the MOMENT.OUT file
        if (associated(input%groundstate%spin)) close(63)

    end if
    
! xml output
    if (rank==0) then
        call structure_xmlout
        call scl_xml_setGndstateStatus("finished")
        call scl_xml_out_write
    end if
    call timesec(ts1)
    timeio=ts1-ts0+timeio
    
!! TIME - End of fifth IO segment
    Call timesec(tsg1)
    If ((rank .Eq. 0).and.(input%groundstate%outputlevelnumber>1)) then
        write(string,'("Timings (seconds)")') 
        call printbox(60,"-",string)
        Write (60, '(" initialisation", T40, ": ", F12.2)') timeinit
        Write (60, '("            - init0", T40,": ", F12.2)') time_init0
        Write (60, '("            - init1", T40,": ", F12.2)') time_init1
        Write (60, '("            - rhoinit", T40,": ", F12.2)') time_density_init
        Write (60, '("            - potential initialisation", T40,": ", F12.2)') time_pot_init
        Write (60, '("            - others", T40,": ", F12.2)') timeinit-time_init0-time_init1-time_density_init-time_pot_init
        Write (60, '(" Hamiltonian and overlap matrix set up", T40, ": ", F12.2)') timemat
        Write (60, '("            - hmlaan", T40,": ", F12.2)') time_hmlaan
        Write (60, '("            - hmlalon", T40,": ", F12.2)') time_hmlalon
        Write (60, '("            - hmllolon", T40,": ", F12.2)') time_hmllolon
        Write (60, '("            - olpaan", T40,": ", F12.2)') time_olpaan
        Write (60, '("            - olpalon", T40,": ", F12.2)') time_olpalon
        Write (60, '("            - olplolon", T40,": ", F12.2)') time_olplolon
        Write (60, '("            - hmlistln", T40,": ", F12.2)') time_hmlistln
        Write (60, '("            - olpistln", T40,": ", F12.2)') time_olpistln
        Write (60, '(" first-variational secular equation", T40, ": ", F12.2)') timefv
        If (associated(input%groundstate%spin)) Then
            Write (60, '(" second-variational calculation", T40, ": ", F12.2)') timesv
        End If
        Write (60, '(" charge density calculation", T40, ": ", F12.2)') timerho
        Write (60, '(" potential calculation", T40, ": ", F12.2)') timepot
        Write (60, '(" muffin-tin manipulations", T40, ": ", F12.2)') timemt
        Write (60, '(" APW matching", T40, ": ", F12.2)') timematch
        Write (60, '(" disk reads/writes", T40, ": ", F12.2)') timeio
        Write (60, '(" mixing efforts", T40, ": ", F12.2)') timemixer
        If (input%groundstate%tforce) Write (60, '(" force calculation", T40, ": ", F12.2)') timefor
        timetot = timeinit + timemat + timefv + timesv + timerho + &
        &         timepot + timefor+timeio+timemt+timemixer+timematch
        Write (60, '(" sum", T40, ": ", F12.2)') timetot
        Write (60, '(" Dirac eqn solver", T40, ": ", F12.2)') time_rdirac
        Write (60, '(" Rel. Schroedinger eqn solver", T40, ": ", F12.2)') time_rschrod
        Write (60, '(" Total time spent in radial solvers", T40, ": ", F12.2)') time_rdirac+time_rschrod
        write (60,*)
    end if

    If (rank .Eq. 0) then
        Write (60, '(" Total time spent (seconds)", T40, ": ", F12.2)') tsg1-tsg0
        if (lwarning) call printbox(60,"-","CAUTION! Warnings have been written in file WARNING.OUT !")
        write(string,'("EXCITING ", a, " stopped")') trim(versionname)
        call printbox(60,"=",string)
        close (60)
    endif
   
!----------------------------------------
! Save HF energies into binary file
!----------------------------------------

    Inquire (IoLength=Recl) kset%nkpt, nstsv, kset%vkl(:,1), evalsv(:,1)
    Open(70, File='EVALHF.OUT', Action='WRITE', Form='UNFORMATTED', &
    &    Access='DIRECT', status='REPLACE', Recl=Recl)
    ! do ik = 1, kset%nkpt
    !    write(70, Rec=ik) kset%nkpt, nstsv, kset%vkl(:,ik), evalsv(:,ik)
    ! end do ! ik
    do ik = 1, kqset%nkpt
       write(70, Rec=ik) kqset%nkpt, nstsv, kqset%vkl(:,ik), evalsv(:,kset%ik2ikp(ik))
    end do ! ik
    Close(70)

!----------------------------------------
! Clean data
!----------------------------------------
    close(600) ! HYBRIDS.OUT
    call delete_core_states
    call delete_product_basis
    call exit_hybrids
    nullify(input%gw)
      
    Return
End Subroutine
!EOC

