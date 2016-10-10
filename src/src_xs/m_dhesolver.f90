module m_dhesolver

  implicit none

  contains

    !BOP
    ! !ROUTINE: dhesolver
    ! !INTERFACE:
    subroutine dhesolver(solsize, ham, evec, eval, eecs)
    ! !USES:
      use modmpi 
      use modsclbse
    ! !INPUT/OUTPUT PARAMETERS:
    ! IN:
    !   integer(4) :: solsize        ! Number of solutions from lowest EV 
    !   integer(4), optional :: eecs ! Estimate for eigenfvalue clustering, defaults to 3
    ! IN/OUT:
    !   type(dzmat) :: ham         ! 2D block cyclic distributed hermitian matrix 
    !   type(dzmat) :: evec        ! 2D block cyclic distributed eigenvector matrix
    !   real(8) :: eval(ham%nrows) ! Real valued eigenvalues in ascending order 
    !                              ! (the first solsize elements are set)
    !
    ! !DESCRIPTION:
    !   Takes the upper triangular part of an distributed complex matrix matrix,
    !   assumed to be hermitian and finds eigenvalues and eigenvectors using 
    !   the scalapack routine {\tt pzheevx}.
    ! 
    ! !REVISION HISTORY:
    !   Created 2016 (Aurich)
    !EOP
    !BOC

      implicit none

      ! Arguments
      integer, intent(in) :: solsize
      integer, intent(in), optional :: eecs
      type(dzmat), intent(inout) :: ham
      type(dzmat), intent(inout) :: evec
      real(8), intent(inout) :: eval(:)

      ! Local variables
      integer(4) :: info
      integer(4) :: lwork, lrwork, liwork
      integer(4) :: il, iu
      real(8) :: abstol, vl, vu
      complex(8), allocatable :: work(:)
      real(8), allocatable :: rwork(:)
      integer(4), allocatable :: iwork(:)
#ifdef SCAL
      real(8) :: orfac
      integer(4) :: ia, ja, iz, jz
      integer(4) :: nevalfound, nevecfound
      real(8), allocatable :: gap(:)
      integer(4), allocatable :: iclustr(:), ifail(:)
      integer(4) :: clusterguess
#else
      integer(4), allocatable :: isuppz(:)
#endif

      ! External functions
#ifdef SCAL
      real(8), external :: pdlamch
#else
      real(8), external :: dlamch
#endif

      ! Sanity check
      if(solsize < 1 .or. solsize > ham%nrows) then
        if(rank == 0) then
          write(*,*) "distributed_hermitian_solver (ERROR):&
            & Number of requested solutions is &
            & incompatible with size of Hamiltonian."
          write(*,*) "solsize:", solsize
          write(*,*) "hamsize:", ham%nrows
        end if
        call terminate
      end if

      ! Tolerance parameter
#ifdef SCAL
      ! Ortho-normality criterion (1d-3 is default)
      orfac = 1d0-6
      ! Numeric tolerance optimized for eigenvalues
      abstol = 2.0d0 * pdlamch(ictxt2d, 'U') 
#else
      abstol = 2.d0 * dlamch('s')
#endif

      ! Allocate supports
#ifdef SCAL
      allocate(ifail(ham%nrows))
      allocate(iclustr(2*nprow*npcol))
      allocate(gap(nprow*npcol))
#else
      allocate(isuppz(2*solsize))
#endif

#ifdef SCAL
      ! Global coordinates of first element of sub-matrix of ham
      ! (We have no sub-selection here we operate on all of ham)
      ia = 1
      ja = 1
      ! Global coordinates of first element of sub-matrix of evec
      ! (We have no sub-selection here we operate on all of evec)
      iz = 1
      jz = 1

      ! Set guess for eigenvalue clustering
      if(present(eecs)) then
        if(eecs >= 1) then
          clusterguess = eecs
        else
          clusterguess = 3
        end if
      else
        clusterguess = 3
      end if
#endif
      
      if(solsize == ham%nrows) then

        ! Get optimal work array lengths
        call workspacequery('A')
        allocate(work(lwork), rwork(lrwork), iwork(liwork))

#ifdef SCAL
          call pzheevx('V', 'A', 'U', ham%nrows, ham%za, ia, ja, ham%desc,&
            & vl, vu, il, iu, abstol, nevalfound, nevecfound, eval, orfac,&
            & evec%za, iz, jz, evec%desc, work, lwork, rwork, lrwork, iwork, liwork,&
            & ifail, iclustr, gap, info)
#else
          call zheevr('V', 'A', 'U', ham%nrows, ham%za, ham%nrows, vl, vu, il, iu, &
            & abstol, solsize, eval, evec%za, ham%nrows, isuppz, work, lwork, rwork,&
            & lrwork, iwork, liwork, info)
#endif


      else

        ! Smallest and largest eigenvalue indices
        il = 1
        iu = solsize

        ! Get optimal work array lengths
        call workspacequery('I')
        allocate(work(lwork), rwork(lrwork), iwork(liwork))

#ifdef SCAL
          call pzheevx('V', 'I', 'U', ham%nrows, ham%za, ia, ja, ham%desc,&
            & vl, vu, il, iu, abstol, nevalfound, nevecfound, eval, orfac,&
            & evec%za, iz, jz, evec%desc, work, lwork, rwork, lrwork, iwork, liwork,&
            & ifail, iclustr, gap, info)
#else
          call zheevr('V', 'I', 'U', ham%nrows, ham%za, ham%nrows, vl, vu, il, iu, &
            & abstol, solsize, eval, evec%za, ham%nrows, isuppz, work, lwork, rwork,&
            & lrwork, iwork, liwork, info)
#endif

      end if

      if(info .ne. 0) then
#ifdef SCAL
        write(*, '("distributed_hermitian_solver (ERROR):&
          & pzheevx returned non-zero info:", i6)') info
        write(*,*)
        call errorinspect(info)
#else 
        write(*, '("distributed_hermitian_solver (ERROR):&
          & zheevr returned non-zero info:", i6)') info
        write(*,*)
        call errorinspect(info)
#endif
      !call terminate
      end if

#ifdef SCAL
      deallocate(ifail)
      deallocate(iclustr)
      deallocate(gap)
#else
    deallocate(isuppz)
#endif
      deallocate(work, rwork, iwork)

      contains

        subroutine workspacequery(rangetype)

          character(1), intent(in) :: rangetype

#ifdef SCAL
          integer(4) :: nhetrd_lwork, anb, nps, n
          integer(4), external :: pjlaenv, iceil
          integer(4) :: sqnpc

          ! If automatic lwork is smaler than nhetrd_lwork, set it to this value
          n = ham%nrows
          anb = pjlaenv(ictxt2d, 3, 'PZHETTRD', 'L', 0, 0, 0, 0)
          sqnpc = int(sqrt(dble(nprow*npcol)))
          nps = max(numroc(n, 1, 0, 0, sqnpc), 2*anb)
          nhetrd_lwork = n + 2*(anb+1)*(4*nps+2)+(nps+1)*nps

          ! lrwork
          ! to guarntee orthonormal vectors add (clustersize-1)*n to lrwork
#endif

          ! Automatic calcualtion of work array lengths
          lwork=-1
          lrwork=-1
          liwork=-1

          allocate(work(3), rwork(3), iwork(3))

#ifdef SCAL
          call pzheevx('V', rangetype, 'U', ham%nrows, ham%za, ia, ja, ham%desc,&
            & vl, vu, il, iu, abstol, nevalfound, nevecfound, eval, orfac,&
            & evec%za, iz, jz, evec%desc, work, lwork, rwork, lrwork, iwork, liwork,&
            & ifail, iclustr, gap, info)

          ! Adjust workspace
          lwork=max(int(work(1)), nhetrd_lwork)
          lrwork=int(rwork(1)) + (clusterguess-1)*n
          liwork=int(iwork(1))
#else
          call zheevr('V', rangetype, 'U', ham%nrows, ham%za, ham%nrows,&
            & vl, vu, il, iu,&
            & abstol, solsize, eval, evec%za, ham%nrows, isuppz, work, lwork, rwork,&
            & lrwork, iwork, liwork, info)

          lwork=int(work(1))
          lrwork=int(rwork(1))
          liwork=int(iwork(1))
#endif

          deallocate(work, rwork, iwork)

        end subroutine workspacequery

        subroutine errorinspect(ierror)
          integer(4) :: ierror

#ifdef SCAL
          if( ierror < 0) then
            write(*,'("dhesolver@rank",i3," Error cause: Invalid input")') rank
          else if(mod(ierror,2) /= 0) then
            write(*,'("dhesolver@rank",i3," Error cause: Eigenvectors not converged")')&
              & rank
          else if(mod(ierror/2,2) /= 0) then
            write(*,'("dhesolver@rank",i3," Error cause: Reorthogonalization failed,&
              & insufficent workspace. Increase eecs.")') rank
            if(rank == 0) then
              write(*,'("dhesolver@rank",i3," iclustr:")') rank
              write(*,'(I8)') iclustr
            end if
          else if(mod(ierror/4,2) /= 0) then
            write(*,'("dhesolver@rank",i3," Error cause: Not all eigenvectors computed,&
              & insufficent workspace.")') rank
          else if(mod(ierror/8,2) /= 0) then
            write(*,'("dhesolver@rank",i3," Error cause: Eigenvalue comptaion failed")')&
              & rank
          end if
#else
          if( ierror < 0) then
            write(*,'("dhesolver@rank",i3," Error cause: Invalid input")') rank
          else 
            write(*,'("dhesolver@rank",i3," Error cause: Internal error")') rank
          end if
#endif
          
        end subroutine

    end subroutine dhesolver
    !EOC
    
end module m_dhesolver
