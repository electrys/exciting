
subroutine getoccsvgw(fname,ik,vpl,nstsv,occsv)
    use m_getunit
    implicit none
    ! arguments
    character(*) :: fname
    integer, intent(In)  :: ik
    real(8), intent(In)  :: vpl(3)
    integer, intent(In)  :: nstsv
    real(8), intent(Out) :: occsv(nstsv)
    ! local variables
    logical :: exist
    integer :: recl, fid
    integer :: nstsv_, ist
    real(8) :: vpl_(3), t1
    real(8), allocatable :: occsv_(:)
    
    inquire(File=trim(fname),Exist=exist)
    if (exist) then
      call getunit(fid)
      inquire(IoLength=recl) vpl_, nstsv_
      open(fid,File=trim(fname),Action='READ',Form='UNFORMATTED', &
      &    Access='DIRECT',Recl=recl)
      read(fid,Rec=1) nstsv_
      close(fid)
      if (nstsv_<nstsv) then
        write(*,*)
        write(*,'("ERROR(getoccsvgw): Wrong number of states")')
        write(*,'("  input size : ", i8)') nstsv
        write(*,'(" ",a," : ",i8)') trim(fname), nstsv_
        write(*,*)
        stop
      end if
      allocate(occsv_(nstsv_))
      inquire(IoLength=recl) nstsv_, vpl_, occsv_
      open(fid,File=trim(fname),Action='READ',Form='UNFORMATTED', &
      &    Access='DIRECT',Recl=recl)
      read(fid,Rec=ik) nstsv_, vpl_, occsv_
      close(fid)
      t1 = dabs(vpl(1)-vpl_(1)) + &
      &    dabs(vpl(2)-vpl_(2)) + &
      &    dabs(vpl(3)-vpl_(3))
      if (t1 > 1.d-6) then
        write(*,*)
        write(*,'("ERROR(getoccsvgw): Differing vectors for k-point",i8)') ik
        write(*,'("  input vector : ", 3G18.10)') vpl
        write(*,'(" ",a," : ",3G18.10)') trim(fname), vpl_
        write(*,*)
        stop
      end if
      do ist = 1, nstsv
        occsv(ist) = occsv_(ist)
      end do
    else
      write(*,*)
      write(*,'("ERROR(getoccsvgw): File ",a," does not exist!")')  trim(fname)
      write(*,*)
      stop
    end if
      
    return
end subroutine

