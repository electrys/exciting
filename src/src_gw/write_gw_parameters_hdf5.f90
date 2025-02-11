
subroutine write_gw_parameters_hdf5
    use modinput
    use modgw, only : fgwh5
    use mod_hdf5
    implicit none

    call hdf5_write(fgwh5,"/parameters","taskname",input%gw%taskname)
    call hdf5_write(fgwh5,"/parameters","coreflag",input%gw%coreflag)
    call hdf5_write(fgwh5,"/parameters","nempty",input%gw%nempty)
    call hdf5_write(fgwh5,"/parameters","ibgw",input%gw%ibgw)
    call hdf5_write(fgwh5,"/parameters","nbgw",input%gw%nbgw)
    call hdf5_write(fgwh5,"/parameters","ngridq",input%gw%ngridq(1),(/3/))

    call hdf5_create_group(fgwh5,"/parameters","freqgrid")
    call hdf5_write(fgwh5,"/parameters/freqgrid","nomeg",input%gw%freqgrid%nomeg)
    call hdf5_write(fgwh5,"/parameters/freqgrid","freqmax",input%gw%freqgrid%freqmax)
    call hdf5_write(fgwh5,"/parameters/freqgrid","fgrid",input%gw%freqgrid%fgrid)
    call hdf5_write(fgwh5,"/parameters/freqgrid","fconv",input%gw%freqgrid%fconv)

    call hdf5_create_group(fgwh5,"/parameters","selfenergy")
    call hdf5_write(fgwh5,"/parameters/selfenergy","nempty",input%gw%selfenergy%nempty)
    call hdf5_write(fgwh5,"/parameters/selfenergy","eqpsolver",input%gw%selfenergy%eqpsolver)
    call hdf5_write(fgwh5,"/parameters/selfenergy","eshift",input%gw%selfenergy%eshift)
    call hdf5_write(fgwh5,"/parameters/selfenergy","actype",input%gw%selfenergy%actype)

    call hdf5_create_group(fgwh5,"/parameters","mixbasis")
    call hdf5_write(fgwh5,"/parameters/mixbasis","lmaxmb",input%gw%mixbasis%lmaxmb)
    call hdf5_write(fgwh5,"/parameters/mixbasis","epsmb",input%gw%mixbasis%epsmb)
    call hdf5_write(fgwh5,"/parameters/mixbasis","gmb",input%gw%mixbasis%gmb)

    call hdf5_create_group(fgwh5,"/parameters","barecoul")
    call hdf5_write(fgwh5,"/parameters/barecoul","pwm",input%gw%barecoul%pwm)
    call hdf5_write(fgwh5,"/parameters/barecoul","stctol",input%gw%barecoul%stctol)
    call hdf5_write(fgwh5,"/parameters/barecoul","cutofftype",input%gw%barecoul%cutofftype)

    call hdf5_create_group(fgwh5,"/parameters","scrcoul")
    ! call hdf5_write(fgwh5,"/parameters/scrcoul","q0eps",input%gw%scrcoul%q0eps(1),(/3/))

    return
end subroutine
