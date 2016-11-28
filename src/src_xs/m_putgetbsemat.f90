module m_putgetbsemat
  use modinput
  use modmpi
  use m_getunit
  use m_genfilname
  use modbse
  use mod_qpoint, only: vql

  implicit none

  private

  ! Meta data for saved W and V arrays
  integer(4) :: nk_bse_, nou_bse_max_
  integer(4), allocatable :: kousize_(:), smap_(:,:), kmap_bse_gr_(:)

  logical :: writemeta=.true., readmeta=.true.

  public :: b_putbseinfo, b_getbseinfo, b_putbsemat, b_getbsemat, b_putbsereset

  contains

    !BOP
    ! !ROUTINE: b_putbseinfo
    ! !INTERFACE:
    subroutine b_putbseinfo(fname, iqmt)
    ! !USES:
    ! !INPUT/OUTPUT PARAMETERS:
    ! IN:
    ! character(*) :: fname    ! Output file name 
    !
    ! !DESCRIPTION:
    !   The routine write supporting information about
    !   a BSE calculation to file.
    !
    ! !REVISION HISTORY:
    !   Created. (Aurich)
    !EOP
    !BOC

      implicit none

      ! Arguments
      character(*), intent(in) :: fname
      integer(4), intent(in) :: iqmt

      ! Local variables
      integer(4) :: reclen, un
      logical :: reducek
      integer(4) :: ngridk(3), ngridq(3)
      real(8) :: vkloff(3)

      reducek = input%xs%reducek
      ngridk = input%xs%ngridk
      ngridq = input%xs%ngridq
      vkloff = input%xs%vkloff

      call getunit(un)

      ! Get large enough record length 
      inquire(iolength=reclen)&
        & reducek, ngridk, ngridq, vkloff,&
        & energyselect, wl, wu, econv,&
        & iqmt, vql(:,1),&
        & nk_max, nk_bse, nou_bse_max, hamsize,&
        & kmap_bse_rg, kmap_bse_gr,&
        & koulims, kousize, smap

      ! Only the master is performing file i/o
      open(unit=un, file=trim(fname), form='unformatted', action='write',&
        & access='direct', status='replace', recl=reclen)

      write(un, rec=1)& 
        & reducek, ngridk, ngridq, vkloff,&
        & energyselect, wl, wu, econv,&
        & iqmt, vql(:,1),&
        & nk_max, nk_bse, nou_bse_max, hamsize,&
        & kmap_bse_rg, kmap_bse_gr,&
        & koulims, kousize, smap

      close(un)
!write(*,*) "(b_putbseinfo) write:"
!write(*,*) "(b_putbseinfo) reducek", reducek
!write(*,*) "(b_putbseinfo) ngridk", ngridk
!write(*,*) "(b_putbseinfo) ngridq", ngridq
!write(*,*) "(b_putbseinfo) vkloff", vkloff
!write(*,*) "(b_putbseinfo) energyselect", energyselect
!write(*,*) "(b_putbseinfo) wl, wu, econv", wl, wu, econv
!write(*,*) "(b_putbseinfo) iqmt, vql", iqmt, vql(:,1)
!write(*,*) "(b_putbseinfo) nk_max, nk_bse, nou_bse_max", nk_max, nk_bse, nou_bse_max
!write(*,*) "(b_putbseinfo) hamsize", hamsize
    end subroutine b_putbseinfo
    !EOC

    !BOP
    ! !ROUTINE: b_getbseinfo
    ! !INTERFACE:
    subroutine b_getbseinfo(fname, iqmt, fcmpt, fid)
    ! !USES:
    ! !INPUT/OUTPUT PARAMETERS:
    ! IN:
    ! integer(4) :: iqmt ! index of momentum transfer vector
    !
    ! !DESCRIPTION:
    !   The routine reads supporting information about
    !   a saved BSE calculation. And compared it to 
    !   the requested inforamtion.
    !
    ! !REVISION HISTORY:
    !   Created. (Aurich)
    !EOP
    !BOC

      implicit none

      ! Arguments
      character(*), intent(in) :: fname
      integer(4), intent(in) :: iqmt
      logical, intent(out), optional :: fcmpt, fid

      ! Local variables
      integer(4) :: reclen, un
      logical :: ishere

      logical :: reducek, reducek_
      integer(4) :: ngridk(3), ngridq(3)
      integer(4) :: ngridk_(3), ngridq_(3)
      real(8) :: vkloff(3), vkloff_(3)

      logical :: iscompatible, isidentical
      logical :: energyselect_
      real(8) :: wl_, wu_, econv_, vql_(3)
      integer(4) :: iqmt_, nk_max_, hamsize_
      integer(4), allocatable :: kmap_bse_rg_(:)
      integer(4), allocatable :: koulims_(:,:)


      reducek = input%xs%reducek
      ngridk = input%xs%ngridk
      ngridq = input%xs%ngridq
      vkloff = input%xs%vkloff

      ! Check if file exists
      inquire(file=trim(fname), exist=ishere)
      if(.not. ishere) then 
        write(*,*) "Error (b_getbseifo): file does not exsist fname=",trim(fname)
        call terminate
      end if

      call getunit(un)
!write(*,*) "(b_getbseinfo) reading form ", trim(infofname)
      ! Get large enough record length 
      inquire(iolength=reclen)&
        & reducek_, ngridk_, ngridq_, vkloff_,&
        & energyselect_, wl_, wu_, econv_,&
        & iqmt_, vql_,&
        & nk_max_, nk_bse_, nou_bse_max_, hamsize_
      open(unit=un, file=trim(fname), form='unformatted', action='read',&
        & access='direct', recl=reclen)
      read(un, rec=1)& 
        & reducek_, ngridk_, ngridq_, vkloff_,&
        & energyselect_, wl_, wu_, econv_,&
        & iqmt_, vql_,&
        & nk_max_, nk_bse_, nou_bse_max_, hamsize_
      close(un)

!write(*,*) "(b_getbseinfo) read:"
!write(*,*) "(b_getbseinfo) reducek_", reducek_
!write(*,*) "(b_getbseinfo) ngridk_", ngridk_
!write(*,*) "(b_getbseinfo) ngridq_", ngridq_
!write(*,*) "(b_getbseinfo) vkloff_", vkloff_
!write(*,*) "(b_getbseinfo) energyselect_", energyselect_
!write(*,*) "(b_getbseinfo) wl_, wu_, econv_", wl_, wu_, econv_
!write(*,*) "(b_getbseinfo) iqmt_, vql_", iqmt_, vql_
!write(*,*) "(b_getbseinfo) nk_max_, nk_bse_, nou_bse_max_", nk_max_, nk_bse_, nou_bse_max_
!write(*,*) "(b_getbseinfo) hamsize_", hamsize_

      ! Defaults
      isidentical = .false.
      iscompatible = .true.

      ! Check if identical
      if( reducek_ == reducek .and. energyselect_ == energyselect&
        & .and. wl_ == wl .and. wu_ == wu .and. econv_ == econv&
        & .and. iqmt_ == iqmt .and. nk_max_ == nk_max .and. nk_bse_ == nk_bse&
        & .and. hamsize_ == hamsize) then
        if( .not. (any(ngridk_ /= ngridk) .or. any(ngridq_ /= ngridq)&
          &.or. any(vkloff_ /= vkloff)) ) then
          isidentical = .true.
          iscompatible = .true.
        end if
      end if

      ! Check necessary compatibility
      if( reducek_ /= reducek) then
        iscompatible = .false.
        isidentical = .false.
        write(*, '("Error (b_getbseinfo):&
          & reducek_ /= reducek")')
        write(*, '(" requested: ",l)') reducek
        write(*, '(" stored: ", l)') reducek_
      end if
      if( any(ngridk_ /= ngridk) .or. any(ngridq_ /= ngridq)&
        &.or. any(vkloff_ /= vkloff)) then
        iscompatible = .false.
        isidentical = .false.
        write(*, '("Error (b_getbseinfo):&
          & ngridk,ngridq or vkloff differ")')
        write(*, '(" requested: ", 3i,1x,3i,1x,3f)') ngridk, ngridq, vkloff 
        write(*, '(" stored: ", 3i,1x,3i,1x,3f)') ngridk_, ngridq_, vkloff_
      end if
      if(iqmt_ /= iqmt) then 
        iscompatible = .false.
        isidentical = .false.
        write(*, '("Error (b_getbseinfo):&
          & Requested momentum transfer index differs")')
        write(*, '(" requested iqmt: ", i4)') iqmt 
        write(*, '(" stored iqmt_: ", i4)') iqmt_
      end if
      if(energyselect_ /= energyselect) then
        iscompatible = .false.
        isidentical = .false.
        write(*, '("Error (b_getbseinfo):&
          & Saved data has different selection mode")')
        write(*, '(" requested enegyselect: ", l)') energyselect 
        write(*, '(" stored energyselect: ", l)') energyselect_
      end if
      if(energyselect) then
        if(wl-econv < wl_-econv_ .or. wu+econv > wu_+econv_) then 
          iscompatible = .false.
          isidentical = .false.
          write(*, '("Error (b_getbseinfo): Requested energy range incompatible")')
          write(*, '(" requested (wl, wu, econv): ", 3E12.3)') wl, wu, econv
          write(*, '(" stored (wl_, wu_, econv_): ", 3E12.3)') wl_, wu_, econv_
        end if
      end if
      if(nk_bse > nk_bse_) then 
        iscompatible = .false.
        isidentical = .false.
        write(*, '("Error (b_getbseinfo): Differring number of relevant k-points")')
        write(*, '(" requested nk_bse: ", i4)') nk_bse 
        write(*, '(" stored nk_bse_: ", i4)') nk_bse_
      end if

      if(iscompatible) then
        if(allocated(kmap_bse_gr_)) deallocate(kmap_bse_gr_)
        allocate(kmap_bse_gr_(nk_max_))
        if(allocated(kousize_)) deallocate(kousize_)
        allocate(kousize_(nk_max_))
        if(allocated(smap_)) deallocate(smap_)
        allocate(smap_(3,hamsize_))

        allocate(kmap_bse_rg_(nk_bse_))
        allocate(koulims_(4,nk_max_))

        ! Get all support info
        call getunit(un)
        inquire(iolength=reclen)&
          & reducek_, ngridk_, ngridq_, vkloff_,&
          & energyselect_, wl_, wu_, econv_,&
          & iqmt_, vql_,&
          & nk_max_, nk_bse_, hamsize_,&
          & kmap_bse_rg_, kmap_bse_gr_,&
          & koulims_, kousize_, smap_
        open(unit=un, file=trim(fname), form='unformatted', action='read',&
          & access='direct', recl=reclen)
        read(un, rec=1)& 
          & reducek_, ngridk_, ngridq_, vkloff_,&
          & energyselect_, wl_, wu_, econv_,&
          & iqmt_, vql_,&
          & nk_max_, nk_bse_, hamsize_,&
          & kmap_bse_rg_, kmap_bse_gr_,&
          & koulims_, kousize_, smap_
        close(un)
      end if

      if(present(fcmpt)) then
        fcmpt = iscompatible
      end if
      if(present(fid)) then
        fid = isidentical
      end if

    end subroutine b_getbseinfo
    !EOC

    !BOP
    ! !ROUTINE: b_putbsereset
    ! !INTERFACE:
    subroutine b_putbsereset
    ! !DESCRIPTION:
    !   Resets module vars.
    !
    ! !REVISION HISTORY:
    !   Created. (Aurich)
    !EOP
    !BOC

      implicit none

      if(allocated(kmap_bse_gr_)) deallocate(kmap_bse_gr_)
      if(allocated(kousize_)) deallocate(kousize_)
      if(allocated(smap_)) deallocate(smap_)
      writemeta = .true.
      readmeta = .true.

    end subroutine b_putbsereset
    !EOC

    !BOP
    ! !ROUTINE: b_putbsemat
    ! !INTERFACE:
    subroutine b_putbsemat(fname, tag, ikkp, iqmt, zmat)
    ! !USES:
    ! !INPUT/OUTPUT PARAMETERS:
    ! IN:
    ! character(*) :: fname    ! Output file name 
    ! integer(4) :: tag        ! MPI communication tag
    ! integer(4) :: ikkp       ! Index of ik jk combination
    ! integer(4) :: iqmt       ! Index of momentum transfer q
    ! complex(8) :: zmat(:,:)  ! Complex 2d-array
    !
    ! !DESCRIPTION:
    !   The routine writes complex 2d-array to a direct access file and
    !   is intended for the use in be BSE part of the code. It is used
    !   to write the screened coulomb interaction {\tt SCCLI.OUT} and 
    !   the exchange interaction {\tt EXCLI.OUT} to file.
    !
    ! !REVISION HISTORY:
    !   Forked from {\tt putbsemat}. (Aurich)
    !EOP
    !BOC

      implicit none

      ! Arguments
      character(*), intent(in) :: fname
      integer(4), intent(in) :: tag
      integer(4), intent(in) :: ikkp, iqmt
      complex(8), intent(in) :: zmat(nou_bse_max,nou_bse_max)

      ! Local variables
      integer(4) :: reclen, un
      integer(4) :: ik, jk, iknr, jknr
      integer(4) :: inou, jnou
      integer(4) :: buffer(5)


#ifdef MPI
      integer(4) :: iproc, stat(mpi_status_size)
#endif

      ! Get individual ik jk index form compined ikkp index
      call kkpmap(ikkp, nk_bse, ik, jk)

      ! Get absolute non-reduced iknr jknr indices
      iknr = kmap_bse_rg(ik)
      jknr = kmap_bse_rg(jk)

      ! Get number of transitions considered at ik and jk
      inou = kousize(iknr)
      jnou = kousize(jknr)

      ! Send/Receive buffer
      buffer = [ikkp, iknr, jknr, inou, jnou]

      call getunit(un)

      ! Get large enough record length (size of zmat can depend on ikkp)
      inquire(iolength=reclen) iqmt, buffer, zmat

#ifdef MPI

      ! Send result to rank 0
      if(mpiglobal%rank .ne. 0) then
        call mpi_send(buffer, size(buffer), mpi_integer, 0,&
          & tag*2, mpiglobal%comm, mpiglobal%ierr)
        call mpi_send(zmat, size(zmat), mpi_double_complex, 0,&
          & tag, mpiglobal%comm, mpiglobal%ierr)
      end if

      if(mpiglobal%rank .eq. 0) then

        ! Recive results form current process column
        ! (see documentaion of lastproc)
        do iproc = 0, lastproc(ikkp, nkkp_bse)

          if(iproc .ne. 0) then
            ! Receive data from slaves
            call mpi_recv(buffer, size(buffer), mpi_integer, iproc, tag*2,&
              & mpiglobal%comm, stat, mpiglobal%ierr)
            call mpi_recv(zmat, size(zmat), mpi_double_complex, iproc, tag,&
              & mpiglobal%comm, stat, mpiglobal%ierr)
          end if
#endif
          ! Only the master is performing file i/o
          open(unit=un, file=trim(fname), form='unformatted', action='write',&
            & access='direct', recl=reclen)
          ! Use ikkp as record index
          write(un, rec=buffer(1)) iqmt, buffer, zmat(1:buffer(4),1:buffer(5))
          close(un)
#ifdef MPI
        end do
      end if
#endif
    end subroutine b_putbsemat
    !EOC

    !BOP
    ! !ROUTINE: b_getbsemat
    ! !INTERFACE:
    subroutine b_getbsemat(fname, iqmt, ikkp, zmat, check, fcmpt, fid)
    ! !DESCRIPTION:
    !   This routine is used for reading the screened coulomb interaction
    !   and exchange interaction from file. It works for ou,ou combinations.
    !
    ! !REVISION HISTORY:
    !   Added to documentation scheme. (Aurich)
    !EOP
    !BOC

      implicit none

      ! Arguments
      character(*), intent(in) :: fname
      integer(4), intent(in) :: iqmt
      integer(4), intent(in) :: ikkp
      complex(8), intent(out) :: zmat(:,:)
      logical, intent(in), optional :: check
      logical, intent(in), optional :: fcmpt
      logical, intent(in), optional :: fid

      ! Local variables
      integer(4) :: un, reclen, zreclen
      integer(4) :: inou_, jnou_, inou, jnou
      integer(4) :: iknr, jknr, ik, jk
      integer(4) :: ik_, jk_, ikkp_, iknr_, jknr_, iqmt_
      integer(4) :: iaoff, jaoff, ia, ja
      integer(4) :: iaoff_, jaoff_, ia_, ja_
      logical, allocatable :: imap(:), jmap(:), ijmap(:,:)
      logical :: ishere, chk
      logical :: iscompatible, isidentical
      complex(8), allocatable :: zm(:,:)
      complex(8) :: dummy

      ! Check if file exists
      inquire(file=trim(fname), exist=ishere)
      if(.not. ishere) then 
        write(*,*) "Error (b_getbsemat): file does not exsist fname=",trim(fname)
        call terminate
      end if

      if(present(check)) then
        chk = check
      else
        chk = .true.
      end if
      ! Inspect meta data of saved computation
      if(chk) then 
write(*,*) "(b_getbsemat) reading meta info from",infofbasename//'_'//trim(fname)
        call b_getbseinfo(infofbasename//'_'//trim(fname), iqmt,&
          & fcmpt=iscompatible, fid=isidentical)
      else
        isidentical = .true.
        iscompatible = .true.
        if(present(fcmpt)) then 
          iscompatible = fcmpt
        end if
        if(present(fid)) then 
          isidentical = fid
        end if
      end if

      if(.not. iscompatible) then
        write(*,*) "Error (b_getbsemat): Saved data is incompatible"
        call terminate
      end if

      if(isidentical) then

        ! Get full record length
        inquire(iolength=zreclen) dummy
        inquire(iolength=reclen) iqmt_, ikkp_, iknr_, jknr_, inou_, jnou_
        reclen = reclen+nou_bse_max_**2*zreclen
        
!write(*,*) "(b_getbsemat) data is identical, reclen", reclen 

        call getunit(un)
        open(unit=un, file=trim(fname), form='unformatted',&
          & action='read', access='direct', recl=reclen)
        
        read(un, rec=ikkp) iqmt_, ikkp_, iknr_, jknr_, inou_, jnou_, zmat 
        close(un)

      else if(iscompatible) then

        ! Get requested quantities for comparison to stored ones
        call kkpmap(ikkp, nk_bse, ik, jk)
        iknr = kmap_bse_rg(ik)
        jknr = kmap_bse_rg(jk)
        ! Get array dimensions
        inou = size(zmat,1)
        jnou = size(zmat,2)
        if(inou /= kousize(iknr) .or. jnou /= kousize(jknr)) then
          write(*,*) "Unexpected matrix size:"
          write(*,*) "inou, jnou", inou, jnou
          write(*,*) "kousize(iknr), kousize(jknr)", kousize(iknr), kousize(jknr)
          call terminate
        end if

        ! Determine which record to read 
        ik_ = kmap_bse_gr_(iknr)
        jk_ = kmap_bse_gr_(jknr)
        if(ik_ < 1 .or. jk_ < 1) then
          write(*,*) "File does not contain requested ik, jk"
          write(*,*) "ik_, jk_", ik_, jk_
          call terminate
        end if
        call kkpmap_back(ikkp_, nk_bse_, ik_, jk_)

        ! Determine size of saved matrix
        inou_ = kousize_(iknr)
        jnou_ = kousize_(jknr)

        ! Get full saved matrix
        allocate(zm(inou_, jnou_))
        ! Get full record length
        inquire(iolength=zreclen) dummy
        inquire(iolength=reclen) iqmt_, ikkp_, iknr_, jknr_, inou_, jnou_
        reclen = reclen+nou_bse_max_**2*zreclen

        call getunit(un)
        open(unit=un, file=trim(fname), form='unformatted',&
          & action='read', access='direct', recl=reclen)
        read(un, rec=ikkp_) iqmt_, ikkp_, iknr_, jknr_, inou_, jnou_, zm
        close(un)
        if(iknr_ /= iknr .or. jknr_ /= jknr) then
          write(*,*) "Mismatch iknr,jknr /= iknr_,jknr_"
          write(*,*) "iknr, jknr", iknr, jknr
          write(*,*) "iknr_, jknr_", iknr_, jknr_
          call terminate
        end if

        ! Find requested entries in saved matrix
        iaoff_ = sum(kousize_(1:iknr_-1))
        jaoff_ = sum(kousize_(1:jknr_-1))
        iaoff = sum(kousize(1:iknr-1))
        jaoff = sum(kousize(1:jknr-1))
        allocate(imap(inou_))
        imap = .false.
        do ia_=1+iaoff_,inou_+iaoff_
          do ia=1+iaoff, inou+iaoff
            if( all(smap(:,ia) == smap_(:,ia_)) ) then
              imap(ia_) = .true.
            end if
          end do
        end do
        if(count(imap) /= inou) then 
          write(*,*) "Error could not retrive data from file"
          write(*,*) "count(imap), inou", count(imap), inou
          call terminate
        end if
        allocate(jmap(jnou_))
        jmap = .false.
        do ja_=1+jaoff_,jnou_+jaoff_
          do ja=1+jaoff, jnou+jaoff
            if( all(smap(:,ja) == smap_(:,ja_)) ) then
              jmap(ia_) = .true.
            end if
          end do
        end do
        if(count(jmap) /= jnou) then 
          write(*,*) "Error could not retrive data from file"
          write(*,*) "count(jmap), jnou", count(jmap), jnou
          call terminate
        end if
        allocate(ijmap(inou_,jnou_))
        do ia_=1,inou_
          do ja_=1,jnou_
            ijmap(ia_,ja_) = imap(ia_) .and. jmap(ja_)
          end do
        end do

        ! Write output
        zmat = reshape(pack(zm, ijmap), [inou, jnou])

        deallocate(zm)
        deallocate(imap, jmap, ijmap)

      end if

    end subroutine b_getbsemat
    !EOC

end module m_putgetbsemat
