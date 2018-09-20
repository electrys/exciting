
subroutine spectralFunction()
    use modinput
    use modmain
    use modgw
    use mod_frequency
    use mod_vxc
    use mod_aaa_approximant
    use mod_pade
    implicit none
    ! local variables
    type(aaa_approximant) :: aaa_minus, aaa_plus
    integer(4) :: nw, iw, iom
    real(8)    :: wmin, wmax, div, eta
    real(8)    :: sRe, sIm, enk
    complex(8) :: sc, zw, dsc
    
    integer(4) :: ik, ie, n
    character(80) :: axis, frmt1, frmt2
        
    ! parameters of the functions fitting the selfenergy
    real(8),    allocatable :: w(:), sf(:,:,:)
    complex(8), allocatable :: zj(:), fj(:)
    complex(8), allocatable :: sc_ac(:,:,:)

    !-----------------
    ! Initialization
    !-----------------
    call init0
    input%groundstate%stypenumber = -1
    call init1
    call init_kqpoint_set
 
    nvelgw = chgval-occmax*dble(ibgw-1)
    nbandsgw = nbgw-ibgw+1

    if (allocated(evalks)) deallocate(evalks)
    allocate(evalks(ibgw:nbgw,kset%nkpt))
    if (allocated(evalqp)) deallocate(evalqp)
    allocate(evalqp(ibgw:nbgw,kset%nkpt))
    call readevalqp()

    allocate(vxcnn(ibgw:nbgw,kset%nkpt))
    call read_vxcnn()
    
    call init_selfenergy(ibgw,nbgw,kset%nkpt)
    call readselfx()
    call readselfc()

    ! Frequency grid for the spectral function
    if ( .not.associated(input%gw%selfenergy%SpectralFunctionPlot) ) &
        input%gw%selfenergy%SpectralFunctionPlot => getstructspectralfunctionplot(emptynode)
    nw   = input%gw%selfenergy%SpectralFunctionPlot%nwgrid
    wmin = input%gw%selfenergy%SpectralFunctionPlot%wmin
    wmax = input%gw%selfenergy%SpectralFunctionPlot%wmax
    axis = trim(input%gw%selfenergy%SpectralFunctionPlot%axis)
    eta  = input%gw%selfenergy%SpectralFunctionPlot%eta
    
    allocate( w(nw) )
    w(:) = 0.d0  
    div  = (wmax-wmin) / dble(nw-1)
    do iw = 1, nw
        w(iw) = wmin + dble(iw-1)*div
    end do

    allocate(zj(freq_selfc%nomeg), fj(freq_selfc%nomeg))

    allocate(sc_ac(ibgw:nbgw,nw,kset%nkpt))
    sc_ac(:,:,:) = zzero
    allocate(sf(ibgw:nbgw,nw,kset%nkpt))
    sf(:,:,:) = zzero

    do ik = 1, kset%nkpt
        do ie = ibgw, nbgw

            ! Positive frequencies
            do iom = 1, freq_selfc%nomeg
                zj(iom) = cmplx(0.d0, freq_selfc%freqs(iom), 8)
                fj(iom) = selfec(ie,iom,ik)
            end do
            
            if (input%gw%selfenergy%actype == 'aaa' ) then
                ! Compute the approximant
                call set_aaa_approximant(aaa_plus, zj, conjg(fj))
                if ( .true. ) then
                    print*, ''
                    print*, 'Number of support points: ', aaa_plus%nj
                    ! print*, 'Weights:', aaa_plus%wj(:)
                    ! print*, 'Errors:', aaa_plus%ej(:)
                    print*, ''
                end if
                ! Negative frequencies
                call init_aaa_approximant(aaa_minus, aaa_plus%nj, -aaa_plus%zj, &
                                          conjg(aaa_plus%fj), conjg(aaa_plus%wj), aaa_plus%ej)
            end if

            enk = evalks(ie,ik) - eferks

            do iw = 1, nw
            
                zw = cmplx( w(iw), 0.d0, 8 )
                ! zw = cmplx( 0.d0, w(iw), 8 )

                ! AAA
                if ( w(iw) > 0.d0 ) then

                    if (input%gw%selfenergy%actype == 'aaa' ) then
                        sc = reval_aaa_approximant( aaa_minus, zw )
                    else if (input%gw%selfenergy%actype == 'pade' ) then
                        call pade_approximant(size(zj), zj, fj, zw, sc, dsc)
                    end if

                else

                    if (input%gw%selfenergy%actype == 'aaa' ) then
                        sc = reval_aaa_approximant( aaa_plus, zw )
                    else if (input%gw%selfenergy%actype == 'pade' ) then
                        call pade_approximant(size(zj), conjg(zj), conjg(fj), zw, sc, dsc)
                    end if

                end if

                ! AC correlation self-energy
                sc_ac(ie,iw,ik) = sc

                ! Spectral function
                sRe = dble( selfex(ie,ik) + sc_ac(ie,iw,ik) )
                sIm = aimag( sc_ac(ie,iw,ik) )
                div = ( w(iw) - enk - sRe + dble( vxcnn(ie,ik) ) )**2 + sIm**2
                sf(ie,iw,ik) = 1.d0/pi * abs(sIm) / div

            end do
            
            ! exit

        end do ! ie
   
        ! exit

    end do ! ik

    ! Format specification
    n = nbgw-ibgw+1
    write(frmt1,'("(",i8,"f14.6)")') 1+n
    write(frmt2,'("(",i8,"f14.6)")') 1+2*n
    ! write(*,*) trim(frmt1), trim(frmt2)

    ! Output
    open(70,file='SpectralFunction.dat',form='FORMATTED',status='UNKNOWN',action='WRITE')
    open(71,file='SelfC-AC.dat',form='FORMATTED',status='UNKNOWN',action='WRITE')
    do ik = 1, kset%nkpt
        write(70,*) '# ik = ', ik
        write(71,*) '# ik = ', ik
        do iw = 1, nw
            write(70,trim(frmt1)) w(iw), sf(:,iw,ik)
            write(71,trim(frmt2)) w(iw), sc_ac(:,iw,ik)
        end do
        write(70,*); write(70,*)
        write(71,*); write(71,*)
    end do
    close(70)
    close(71)

    ! clear memory
    deallocate(w, zj, fj)
    call delete_selfenergy
    deallocate(vxcnn)
    deallocate(sc_ac, sf)
      
    return
end subroutine