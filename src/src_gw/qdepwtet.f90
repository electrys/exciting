!BOP
!
!!ROUTINE: qdepwtet
!
!!INTERFACE:
!
subroutine qdepwtet(iq,iomstart,iomend,ndim)
!
!!DESCRIPTION:
!
! This subroutine calculates the weights for q dependent BZ integration
! using LIBBZINT
!
!
!!USES:
    use modinput
    use modmain, only : natmtot, zzero, nspecies, natoms, idxas, &
    &                   evalcr, efermi
    use modgw,   only : fnm, freq, ncmax, kset, kqset, nomax, numin, &
    &                   ncg, corind, fdebug, time_bzinit, evalfv, nstdf

!!INPUT PARAMETERS:
    implicit none
    integer(4), intent(in) :: iq
    integer(4), intent(in) :: iomstart, iomend
    integer(4), intent(in) :: ndim

!!LOCAL VARIABLES:
    integer(4) :: ik, ikp, ib, ic, icg
    integer(4) :: ia, is, ias
    integer(4) :: iom, n, m
    integer(4) :: fflg, sgw

    real(8) :: emaxb ! maximum energy of the second band
    real(8) :: edif, edsq, omsq
    real(8) :: sfact

    real(8), allocatable :: eval(:,:)
    real(8), allocatable :: cwpar(:,:,:)
    real(8), allocatable :: cwparsurf(:,:,:)

    real(8) :: tstart, tend

!EOP
!BOC
    call timesec(tstart)

    !---------------------------------------------------------------------
    ! Initialization
    !---------------------------------------------------------------------
    if (allocated(fnm)) deallocate(fnm)
    allocate(fnm(1:ndim,numin:nstdf,iomstart:iomend,kqset%nkpt))
    fnm(:,:,:,:) = zzero

    ! real or imaginary frequencies
    select case (freq%fconv)
      case('nofreq')
        fflg = 1
      case('refreq')
        fflg = 2
      case('imfreq')
        fflg = 3
    end select
    sgw = 5-2*fflg

    !====================
    ! valence-valence
    !====================
    allocate(eval(nstdf,kqset%nkpt))
    do ik = 1, kqset%nkpt
      ikp = kset%ik2ikp(ik)
      eval(1:nstdf,ik) = evalfv(1:nstdf,ikp)
    end do

    allocate(cwpar(nstdf,nstdf,kqset%nkpt))
    if (fflg==2) then
      allocate(cwparsurf(nstdf,nstdf,kqset%nkpt))
    end if

    do iom = iomstart, iomend
      call tetcw(kqset%nkpt, kqset%ntet, nstdf, kqset%wtet, &
                 eval, &
                 kqset%tnodes, kqset%linkq(:,iq), kqset%kqid(:,iq), &
                 kqset%tvol, efermi, freq%freqs(iom), fflg, &
                 cwpar)
      if (fflg==2) then
        call tetcw(kqset%nkpt, kqset%ntet, nstdf, kqset%wtet, &
                   eval, &
                   kqset%tnodes, kqset%linkq(:,iq), kqset%kqid(:,iq), &
                   kqset%tvol, efermi, freq%freqs(iom), 4, &
                   cwparsurf)
      end if
      do ik = 1, kqset%nkpt
        do ib = 1, nstdf
          if (eval(ib,kqset%kqid(ik,iq)) > 900.0) cwpar(1:nstdf,ib,ik) = 0.0d0
          if (fflg == 2) then
            if (eval(ib,kqset%kqid(ik,iq)) > 900.0) cwparsurf(1:nstdf,ib,ik) = 0.0d0
          end if
        end do
      end do
      ! the factor 2 comes from the spin degeneracy
      if (fflg == 2) then
        fnm(1:nomax,numin:nstdf,iom,1:kqset%nkpt) = &
           cmplx(cwpar(1:nomax,numin:nstdf,1:kqset%nkpt), &
                       cwparsurf(1:nomax,numin:nstdf,1:kqset%nkpt))
      else
        fnm(1:nomax,numin:nstdf,iom,1:kqset%nkpt) = &
            cmplx(cwpar(1:nomax,numin:nstdf,1:kqset%nkpt),0.0)
      endif
    enddo ! iom

    deallocate(eval)
    deallocate(cwpar)
    if (fflg == 2) deallocate(cwparsurf)

    !====================
    ! core-valence
    !====================
    if (input%gw%coreflag=='all') then

      allocate(eval(2,kqset%nkpt))
      allocate(cwpar(2,2,kqset%nkpt))

      do icg = 1, ncg
        is = corind(icg,1)
        ia = corind(icg,2)
        ic = corind(icg,3)
        ias = idxas(ia,is)
        eval(1,1:kqset%nkpt) = evalcr(ic,ias)

        do ib = numin, nstdf
          do ik = 1, kqset%nkpt
            ikp = kset%ik2ikp(ik)
            eval(2,ik) = evalfv(ib,ikp)
          end do
          ! continue only if the band is at least partially unoccupied
          emaxb = maxval(eval(2,:))
          if (emaxb > efermi) then
            do iom = iomstart, iomend
              omsq = sgw*freq%freqs(iom)*freq%freqs(iom)
              call tetcw(kqset%nkpt,kqset%ntet,2,kqset%wtet, &
              &          eval,&
              &          kqset%tnodes,kqset%linkq(:,iq),kqset%kqid(:,iq), &
              &          kqset%tvol,efermi,freq%freqs(iom),1, &
              &          cwpar)
              do ik = 1, kqset%nkpt
                ikp = kset%ik2ikp(ik)
                edif = evalfv(ib,ikp)-evalcr(ic,ias)
                edsq = edif*edif
                fnm(nomax+icg,ib,iom,ik) = 2.0d0*cwpar(1,2,ik)*edif/(omsq-edsq) ! <-- why 2?
              end do
              if (fflg==2) then
                call tetcw(kqset%nkpt, kqset%ntet, 2, kqset%wtet, &
                           eval, &
                           kqset%tnodes, kqset%linkq(:,iq), kqset%kqid(:,iq), &
                           kqset%tvol, efermi, freq%freqs(iom), 4, &
                           cwpar)
                do ik = 1, kqset%nkpt
                  fnm(nomax+icg,ib,iom,ik) = &
                      cmplx(real(fnm(nomax+icg,ib,iom,ik)),cwpar(1,2,ik))
                end do
              end if
            end do ! iom
          endif
        end do ! ib

      enddo ! icg

      deallocate(eval)
      deallocate(cwpar)

    end if ! core

    ! spin degeneracy: I'm not sure about this prefactor for core states
    sfact = 2.d0
    fnm(:,:,:,:) = sfact*fnm(:,:,:,:)

    !-------------------------
    ! Debugging info
    !-------------------------
    if (input%gw%debug) then
      write(fdebug,*)'------------------------------------------------------'
      write(fdebug,*)'       convolution weights for iq =',iq
      write(fdebug,*)'------------------------------------------------------'
      write(fdebug,*)
      iom = 1
      do ik = 1, kqset%nkpt
        do ic = 1, ndim
        do ib = numin, nstdf
          write(fdebug,1) ic, ib, iom, ik, fnm(ic,ib,iom,ik)
        end do
        end do
      end do
      1 format('  ic =',i4,' ib =',i4,' iom =',i4,' ik =',i4,' fnm =',2g16.8)
    end if ! debug

    ! timing info
    call timesec(tend)
    time_bzinit =  time_bzinit+tend-tstart

    return
end subroutine
!EOC
