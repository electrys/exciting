
module modinput
use inputdom
implicit none
type origin_type
 real(8)::coord(3)
end type
type point_type
 real(8)::coord(3)
 character(512)::label
end type

type point_type_array
type(point_type),pointer::point
 end type
    type plot1d_type
  type(path_type),pointer::path
end type
type path_type
 integer::steps
 character(512)::outfileprefix
  type(point_type_array),pointer::pointarray(:)
end type
type plot2d_type
  type(parallelogram_type),pointer::parallelogram
end type
type parallelogram_type
 integer::grid(2)
 character(512)::outfileprefix
  type(origin_type),pointer::origin
  type(point_type_array),pointer::pointarray(:)
end type
type plot3d_type
  type(box_type),pointer::box
end type
type box_type
 integer::grid(3)
 character(512)::outfileprefix
  type(origin_type),pointer::origin
  type(point_type_array),pointer::pointarray(:)
end type
type kstlist_type
 integer,pointer::pointstatepair(:,:)
end type
type inputset_type
  type(input_type_array),pointer::inputarray(:)
end type
type input_type
 character(1024)::xsltpath
 character(1024)::scratchpath
 character(1024)::id
 character(1024)::depends
 character(512)::title
  type(structure_type),pointer::structure
  type(groundstate_type),pointer::groundstate
  type(structureoptimization_type),pointer::structureoptimization
  type(properties_type),pointer::properties
  type(phonons_type),pointer::phonons
  type(xs_type),pointer::xs
end type

type input_type_array
type(input_type),pointer::input
 end type
    type structure_type
 character(1024)::speciespath
 logical::molecule
 real(8)::epslat
 logical::autormt
 real(8)::vacuum
 logical::primcell
  type(symmetries_type),pointer::symmetries
  type(crystal_type),pointer::crystal
  type(species_type_array),pointer::speciesarray(:)
end type
type symmetries_type
 character(512)::HermannMauguinSymbol
 character(512)::HallSymbol
 character(512)::SchoenfliesSymbol
 character(512)::spaceGroupNumber
  type(lattice_type),pointer::lattice
  type(WyckoffPositions_type),pointer::WyckoffPositions
end type
type lattice_type
 real(8)::a
 real(8)::b
 real(8)::c
 real(8)::ab
 real(8)::ac
 real(8)::bc
 integer::ncell(3)
end type
type WyckoffPositions_type
  type(wspecies_type_array),pointer::wspeciesarray(:)
end type
type wspecies_type
 character(512)::speciesfile
  type(wpos_type_array),pointer::wposarray(:)
end type

type wspecies_type_array
type(wspecies_type),pointer::wspecies
 end type
    type wpos_type
 real(8)::coord(3)
end type

type wpos_type_array
type(wpos_type),pointer::wpos
 end type
    type crystal_type
 real(8)::scale
 real(8)::stretch(3)
 real(8),pointer::basevect(:,:)
end type
type species_type
 character(1024)::speciesfile
 character(512)::chemicalSymbol
 integer::atomicNumber
 real(8)::rmt
  type(atom_type_array),pointer::atomarray(:)
  type(LDAplusu_type),pointer::LDAplusu
end type

type species_type_array
type(species_type),pointer::species
 end type
    type atom_type
 real(8)::coord(3)
 real(8)::bfcmt(3)
end type

type atom_type_array
type(atom_type),pointer::atom
 end type
    type LDAplusu_type
 real(8)::L
 real(8)::U
 real(8)::J
end type
type groundstate_type
 integer::ngkgrid(3)
 real(8)::rgkmax
 real(8)::epspot
 real(8)::rmtapm(2)
 real(8)::swidth
 character(512)::stype
 integer::stypenumber
 integer::isgkmax
 real(8)::gmaxvr
 integer::nempty
 logical::nosym
 logical::autokpt
 real(8)::radkpt
 logical::reducek
 logical::tfibs
 logical::tforce
 integer::lmaxapw
 integer::maxscl
 real(8)::chgexs
 real(8)::deband
 real(8)::epschg
 real(8)::epsocc
 character(512)::mixer
 integer::mixernumber
 logical::fromscratch
 integer::lradstep
 integer::nprad
 character(512)::xctype
 integer::xctypenumber
 real(8)::evalmin
 integer::lmaxvr
 real(8)::fracinr
 integer::lmaxinr
 integer::lmaxmat
 integer::kdotpgrid(3)
 real(8)::vkloff(3)
 integer::npsden
  type(spin_type),pointer::spin
  type(HartreeFock_type),pointer::HartreeFock
  type(solver_type),pointer::solver
end type
type spin_type
 real(8)::bfieldc(3)
 real(8)::momfix(3)
 logical::spinorb
 logical::spinsprl
 real(8)::vqlss(3)
 real(8)::taufsm
 real(8)::reducebf
 character(512)::fixspin
 integer::fixspinnumber
end type

type HartreeFock_type
logical::exists
 end type
    type solver_type
 character(512)::type
 integer::typenumber
 logical::packedmatrixstorage
 character(512)::epsarpack
end type
type structureoptimization_type
 real(8)::epsforce
 real(8)::tau0atm
 logical::resume
end type
type properties_type
  type(bandstructure_type),pointer::bandstructure
  type(STM_type),pointer::STM
  type(wfplot_type),pointer::wfplot
  type(dos_type),pointer::dos
  type(LSJ_type),pointer::LSJ
  type(masstensor_type),pointer::masstensor
  type(chargedesityplot_type),pointer::chargedesityplot
  type(exccplot_type),pointer::exccplot
  type(elfplot_type),pointer::elfplot
  type(mvecfield_type),pointer::mvecfield
  type(xcmvecfield_type),pointer::xcmvecfield
  type(electricfield_type),pointer::electricfield
  type(gradmvecfield_type),pointer::gradmvecfield
  type(fermisurfaceplot_type),pointer::fermisurfaceplot
  type(EFG_type),pointer::EFG
  type(momentummatrix_type),pointer::momentummatrix
  type(linresponsetensor_type),pointer::linresponsetensor
  type(mossbauer_type),pointer::mossbauer
  type(dielectric_type),pointer::dielectric
  type(expiqr_type),pointer::expiqr
  type(elnes_type),pointer::elnes
  type(eliashberg_type),pointer::eliashberg
end type
type bandstructure_type
 real(8)::scissor
 logical::character
  type(plot1d_type),pointer::plot1d
end type
type STM_type
  type(plot2d_type),pointer::plot2d
end type
type wfplot_type
  type(kstlist_type),pointer::kstlist
  type(plot1d_type),pointer::plot1d
  type(plot2d_type),pointer::plot2d
  type(plot3d_type),pointer::plot3d
end type
type dos_type
 logical::lmirep
 integer::nwdos
 integer::ngrdos
 real(8)::scissor
 integer::nsmdos
 real(8)::wintdos(2)
end type
type LSJ_type
  type(kstlist_type),pointer::kstlist
end type
type masstensor_type
 real(8)::deltaem
 integer::ndspem
 real(8)::vklem(3)
end type
type chargedesityplot_type
  type(plot1d_type),pointer::plot1d
  type(plot2d_type),pointer::plot2d
  type(plot3d_type),pointer::plot3d
end type
type exccplot_type
  type(plot1d_type),pointer::plot1d
  type(plot2d_type),pointer::plot2d
  type(plot3d_type),pointer::plot3d
end type
type elfplot_type
  type(plot1d_type),pointer::plot1d
  type(plot2d_type),pointer::plot2d
  type(plot3d_type),pointer::plot3d
end type
type mvecfield_type
  type(plot2d_type),pointer::plot2d
  type(plot3d_type),pointer::plot3d
end type
type xcmvecfield_type
  type(plot2d_type),pointer::plot2d
  type(plot3d_type),pointer::plot3d
end type
type electricfield_type
  type(plot2d_type),pointer::plot2d
  type(plot3d_type),pointer::plot3d
end type
type gradmvecfield_type
  type(plot1d_type),pointer::plot1d
  type(plot2d_type),pointer::plot2d
  type(plot3d_type),pointer::plot3d
end type
type fermisurfaceplot_type
 integer::nstfsp
 logical::separate
end type

type EFG_type
logical::exists
 end type
    
type momentummatrix_type
logical::exists
 end type
    type linresponsetensor_type
 real(8)::scissor
 integer,pointer::optcomp(:,:)
end type

type mossbauer_type
logical::exists
 end type
    
type dielectric_type
logical::exists
 end type
    
type expiqr_type
logical::exists
 end type
    
type elnes_type
logical::exists
 end type
    
type eliashberg_type
logical::exists
 end type
    type phonons_type
  type(qpointset_type),pointer::qpointset
  type(phonondos_type),pointer::phonondos
  type(phonondispplot_type),pointer::phonondispplot
end type

type phonondos_type
logical::exists
 end type
    type phonondispplot_type
  type(plot1d_type),pointer::plot1d
end type
type xs_type
 integer::ngridk(3)
 real(8)::vkloff(3)
 logical::reducek
 integer::ngridq(3)
 logical::nosym
 real(8)::gqmax
 real(8)::rgkmax
 real(8)::lmaxapw
 integer::nempty
 character(512)::xstype
 integer::xstypenumber
  type(tddft_type),pointer::tddft
  type(BSE_type),pointer::BSE
  type(qpointset_type),pointer::qpointset
  type(plan_type),pointer::plan
  type(tetra_type),pointer::tetra
  type(dosWindow_type),pointer::dosWindow
end type
type tddft_type
 logical::dfoffdiag
 integer::emattype
 integer::lmaxapwwf
 integer::lmaxemat
 real(8)::scissor
 real(8)::optswidth
 logical::intraband
 logical::tetradf
 logical::torddf
 logical::acont
 integer::nwacont
 real(8)::broad
 logical::lindhard
 logical::aresdf
 real(8)::epsdfde
 real(8)::emaxdf
 character(512)::fxctype
 integer::fxctypenumber
 logical::kerndiag
 integer::lmaxalda
 real(8)::alphalrc
 real(8)::alphalrcdyn
 real(8)::betalrcdyn
  type(dftrans_type),pointer::dftrans
end type
type dftrans_type
 integer,pointer::trans(:,:)
end type
type BSE_type
 character(512)::tordfxc
 logical::aresfxc
 real(8)::fxcbsesplit
 integer::lmaxdielt
 integer::nleblaik
 integer::nexcitmax
end type
type plan_type
  type(doonly_type_array),pointer::doonlyarray(:)
end type
type doonly_type
 character(512)::task
 integer::tasknumber
end type

type doonly_type_array
type(doonly_type),pointer::doonly
 end type
    type tetra_type
 logical::kordexc
 logical::cw1k
 integer::qweights
end type
type dosWindow_type
 integer::points
 real(8)::emin
 real(8)::emax
end type
type qpointset_type
 real(8),pointer::qpoint(:,:)
end type

   type(input_type)::input
contains

function getstructorigin(thisnode)

implicit none
type(Node),pointer::thisnode
type(origin_type),pointer::getstructorigin
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructorigin)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at origin"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"coord")
if(associated(np)) then
       call extractDataAttribute(thisnode,"coord",getstructorigin%coord)
       call removeAttribute(thisnode,"coord")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructpoint(thisnode)

implicit none
type(Node),pointer::thisnode
type(point_type),pointer::getstructpoint
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructpoint)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at point"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"coord")
if(associated(np)) then
       call extractDataAttribute(thisnode,"coord",getstructpoint%coord)
       call removeAttribute(thisnode,"coord")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"label")
getstructpoint%label= ""
if(associated(np)) then
       call extractDataAttribute(thisnode,"label",getstructpoint%label)
       call removeAttribute(thisnode,"label")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructplot1d(thisnode)

implicit none
type(Node),pointer::thisnode
type(plot1d_type),pointer::getstructplot1d
		
integer::len=1,i=0
allocate(getstructplot1d)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at plot1d"
#endif
      
            len= countChildEmentsWithName(thisnode,"path")
getstructplot1d%path=>null()
Do i=0,len-1
getstructplot1d%path=>getstructpath(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"path"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructpath(thisnode)

implicit none
type(Node),pointer::thisnode
type(path_type),pointer::getstructpath
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructpath)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at path"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"steps")
if(associated(np)) then
       call extractDataAttribute(thisnode,"steps",getstructpath%steps)
       call removeAttribute(thisnode,"steps")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"outfileprefix")
if(associated(np)) then
       call extractDataAttribute(thisnode,"outfileprefix",getstructpath%outfileprefix)
       call removeAttribute(thisnode,"outfileprefix")      
endif

            len= countChildEmentsWithName(thisnode,"point")
     
allocate(getstructpath%pointarray(len))
Do i=0,len-1
getstructpath%pointarray(i+1)%point=>getstructpoint(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"point"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructplot2d(thisnode)

implicit none
type(Node),pointer::thisnode
type(plot2d_type),pointer::getstructplot2d
		
integer::len=1,i=0
allocate(getstructplot2d)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at plot2d"
#endif
      
            len= countChildEmentsWithName(thisnode,"parallelogram")
getstructplot2d%parallelogram=>null()
Do i=0,len-1
getstructplot2d%parallelogram=>getstructparallelogram(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"parallelogram"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructparallelogram(thisnode)

implicit none
type(Node),pointer::thisnode
type(parallelogram_type),pointer::getstructparallelogram
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructparallelogram)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at parallelogram"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"grid")
if(associated(np)) then
       call extractDataAttribute(thisnode,"grid",getstructparallelogram%grid)
       call removeAttribute(thisnode,"grid")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"outfileprefix")
if(associated(np)) then
       call extractDataAttribute(thisnode,"outfileprefix",getstructparallelogram%outfileprefix)
       call removeAttribute(thisnode,"outfileprefix")      
endif

            len= countChildEmentsWithName(thisnode,"origin")
getstructparallelogram%origin=>null()
Do i=0,len-1
getstructparallelogram%origin=>getstructorigin(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"origin"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"point")
     
allocate(getstructparallelogram%pointarray(len))
Do i=0,len-1
getstructparallelogram%pointarray(i+1)%point=>getstructpoint(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"point"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructplot3d(thisnode)

implicit none
type(Node),pointer::thisnode
type(plot3d_type),pointer::getstructplot3d
		
integer::len=1,i=0
allocate(getstructplot3d)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at plot3d"
#endif
      
            len= countChildEmentsWithName(thisnode,"box")
getstructplot3d%box=>null()
Do i=0,len-1
getstructplot3d%box=>getstructbox(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"box"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructbox(thisnode)

implicit none
type(Node),pointer::thisnode
type(box_type),pointer::getstructbox
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructbox)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at box"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"grid")
if(associated(np)) then
       call extractDataAttribute(thisnode,"grid",getstructbox%grid)
       call removeAttribute(thisnode,"grid")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"outfileprefix")
if(associated(np)) then
       call extractDataAttribute(thisnode,"outfileprefix",getstructbox%outfileprefix)
       call removeAttribute(thisnode,"outfileprefix")      
endif

            len= countChildEmentsWithName(thisnode,"origin")
getstructbox%origin=>null()
Do i=0,len-1
getstructbox%origin=>getstructorigin(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"origin"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"point")
     
allocate(getstructbox%pointarray(len))
Do i=0,len-1
getstructbox%pointarray(i+1)%point=>getstructpoint(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"point"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructkstlist(thisnode)

implicit none
type(Node),pointer::thisnode
type(kstlist_type),pointer::getstructkstlist
		
integer::len=1,i=0
allocate(getstructkstlist)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at kstlist"
#endif
      
      len= countChildEmentsWithName (thisnode,"pointstatepair")           
allocate(getstructkstlist%pointstatepair(len,2))
Do i=1,len

		getstructkstlist%pointstatepair(i,:)=getvalueofpointstatepair(&
      removechild(thisnode,item(getElementsByTagname(thisnode,&
      "pointstatepair"),0)))
end do

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructinputset(thisnode)

implicit none
type(Node),pointer::thisnode
type(inputset_type),pointer::getstructinputset
		
integer::len=1,i=0
allocate(getstructinputset)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at inputset"
#endif
      
            len= countChildEmentsWithName(thisnode,"input")
     
allocate(getstructinputset%inputarray(len))
Do i=0,len-1
getstructinputset%inputarray(i+1)%input=>getstructinput(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"input"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructinput(thisnode)

implicit none
type(Node),pointer::thisnode
type(input_type),pointer::getstructinput
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructinput)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at input"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"xsltpath")
getstructinput%xsltpath= "../../xml"
if(associated(np)) then
       call extractDataAttribute(thisnode,"xsltpath",getstructinput%xsltpath)
       call removeAttribute(thisnode,"xsltpath")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"scratchpath")
if(associated(np)) then
       call extractDataAttribute(thisnode,"scratchpath",getstructinput%scratchpath)
       call removeAttribute(thisnode,"scratchpath")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"id")
if(associated(np)) then
       call extractDataAttribute(thisnode,"id",getstructinput%id)
       call removeAttribute(thisnode,"id")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"depends")
if(associated(np)) then
       call extractDataAttribute(thisnode,"depends",getstructinput%depends)
       call removeAttribute(thisnode,"depends")      
endif

            len= countChildEmentsWithName(thisnode,"structure")
getstructinput%structure=>null()
Do i=0,len-1
getstructinput%structure=>getstructstructure(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"structure"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"groundstate")
getstructinput%groundstate=>null()
Do i=0,len-1
getstructinput%groundstate=>getstructgroundstate(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"groundstate"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"structureoptimization")
getstructinput%structureoptimization=>null()
Do i=0,len-1
getstructinput%structureoptimization=>getstructstructureoptimization(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"structureoptimization"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"properties")
getstructinput%properties=>null()
Do i=0,len-1
getstructinput%properties=>getstructproperties(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"properties"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"phonons")
getstructinput%phonons=>null()
Do i=0,len-1
getstructinput%phonons=>getstructphonons(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"phonons"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"xs")
getstructinput%xs=>null()
Do i=0,len-1
getstructinput%xs=>getstructxs(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"xs"),0)) ) 
enddo

      len= countChildEmentsWithName (thisnode,"title")
Do i=1,len

		getstructinput%title=getvalueoftitle(&
      removechild(thisnode,item(getElementsByTagname(thisnode,&
      "title"),0)))
end do

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructstructure(thisnode)

implicit none
type(Node),pointer::thisnode
type(structure_type),pointer::getstructstructure
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructstructure)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at structure"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"speciespath")
if(associated(np)) then
       call extractDataAttribute(thisnode,"speciespath",getstructstructure%speciespath)
       call removeAttribute(thisnode,"speciespath")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"molecule")
getstructstructure%molecule= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"molecule",getstructstructure%molecule)
       call removeAttribute(thisnode,"molecule")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"epslat")
getstructstructure%epslat=1e-6
if(associated(np)) then
       call extractDataAttribute(thisnode,"epslat",getstructstructure%epslat)
       call removeAttribute(thisnode,"epslat")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"autormt")
getstructstructure%autormt= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"autormt",getstructstructure%autormt)
       call removeAttribute(thisnode,"autormt")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"vacuum")
getstructstructure%vacuum=10
if(associated(np)) then
       call extractDataAttribute(thisnode,"vacuum",getstructstructure%vacuum)
       call removeAttribute(thisnode,"vacuum")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"primcell")
getstructstructure%primcell= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"primcell",getstructstructure%primcell)
       call removeAttribute(thisnode,"primcell")      
endif

            len= countChildEmentsWithName(thisnode,"symmetries")
getstructstructure%symmetries=>null()
Do i=0,len-1
getstructstructure%symmetries=>getstructsymmetries(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"symmetries"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"crystal")
getstructstructure%crystal=>null()
Do i=0,len-1
getstructstructure%crystal=>getstructcrystal(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"crystal"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"species")
     
allocate(getstructstructure%speciesarray(len))
Do i=0,len-1
getstructstructure%speciesarray(i+1)%species=>getstructspecies(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"species"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructsymmetries(thisnode)

implicit none
type(Node),pointer::thisnode
type(symmetries_type),pointer::getstructsymmetries
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructsymmetries)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at symmetries"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"HermannMauguinSymbol")
if(associated(np)) then
       call extractDataAttribute(thisnode,"HermannMauguinSymbol",getstructsymmetries%HermannMauguinSymbol)
       call removeAttribute(thisnode,"HermannMauguinSymbol")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"HallSymbol")
if(associated(np)) then
       call extractDataAttribute(thisnode,"HallSymbol",getstructsymmetries%HallSymbol)
       call removeAttribute(thisnode,"HallSymbol")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"SchoenfliesSymbol")
if(associated(np)) then
       call extractDataAttribute(thisnode,"SchoenfliesSymbol",getstructsymmetries%SchoenfliesSymbol)
       call removeAttribute(thisnode,"SchoenfliesSymbol")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"spaceGroupNumber")
if(associated(np)) then
       call extractDataAttribute(thisnode,"spaceGroupNumber",getstructsymmetries%spaceGroupNumber)
       call removeAttribute(thisnode,"spaceGroupNumber")      
endif

            len= countChildEmentsWithName(thisnode,"lattice")
getstructsymmetries%lattice=>null()
Do i=0,len-1
getstructsymmetries%lattice=>getstructlattice(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"lattice"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"WyckoffPositions")
getstructsymmetries%WyckoffPositions=>null()
Do i=0,len-1
getstructsymmetries%WyckoffPositions=>getstructWyckoffPositions(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"WyckoffPositions"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructlattice(thisnode)

implicit none
type(Node),pointer::thisnode
type(lattice_type),pointer::getstructlattice
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructlattice)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at lattice"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"a")
if(associated(np)) then
       call extractDataAttribute(thisnode,"a",getstructlattice%a)
       call removeAttribute(thisnode,"a")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"b")
if(associated(np)) then
       call extractDataAttribute(thisnode,"b",getstructlattice%b)
       call removeAttribute(thisnode,"b")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"c")
if(associated(np)) then
       call extractDataAttribute(thisnode,"c",getstructlattice%c)
       call removeAttribute(thisnode,"c")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"ab")
if(associated(np)) then
       call extractDataAttribute(thisnode,"ab",getstructlattice%ab)
       call removeAttribute(thisnode,"ab")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"ac")
if(associated(np)) then
       call extractDataAttribute(thisnode,"ac",getstructlattice%ac)
       call removeAttribute(thisnode,"ac")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"bc")
if(associated(np)) then
       call extractDataAttribute(thisnode,"bc",getstructlattice%bc)
       call removeAttribute(thisnode,"bc")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"ncell")
getstructlattice%ncell=(/1,1,1/)
if(associated(np)) then
       call extractDataAttribute(thisnode,"ncell",getstructlattice%ncell)
       call removeAttribute(thisnode,"ncell")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructWyckoffPositions(thisnode)

implicit none
type(Node),pointer::thisnode
type(WyckoffPositions_type),pointer::getstructWyckoffPositions
		
integer::len=1,i=0
allocate(getstructWyckoffPositions)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at WyckoffPositions"
#endif
      
            len= countChildEmentsWithName(thisnode,"wspecies")
     
allocate(getstructWyckoffPositions%wspeciesarray(len))
Do i=0,len-1
getstructWyckoffPositions%wspeciesarray(i+1)%wspecies=>getstructwspecies(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"wspecies"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructwspecies(thisnode)

implicit none
type(Node),pointer::thisnode
type(wspecies_type),pointer::getstructwspecies
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructwspecies)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at wspecies"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"speciesfile")
if(associated(np)) then
       call extractDataAttribute(thisnode,"speciesfile",getstructwspecies%speciesfile)
       call removeAttribute(thisnode,"speciesfile")      
endif

            len= countChildEmentsWithName(thisnode,"wpos")
     
allocate(getstructwspecies%wposarray(len))
Do i=0,len-1
getstructwspecies%wposarray(i+1)%wpos=>getstructwpos(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"wpos"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructwpos(thisnode)

implicit none
type(Node),pointer::thisnode
type(wpos_type),pointer::getstructwpos
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructwpos)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at wpos"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"coord")
if(associated(np)) then
       call extractDataAttribute(thisnode,"coord",getstructwpos%coord)
       call removeAttribute(thisnode,"coord")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructcrystal(thisnode)

implicit none
type(Node),pointer::thisnode
type(crystal_type),pointer::getstructcrystal
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructcrystal)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at crystal"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"scale")
getstructcrystal%scale=1
if(associated(np)) then
       call extractDataAttribute(thisnode,"scale",getstructcrystal%scale)
       call removeAttribute(thisnode,"scale")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"stretch")
getstructcrystal%stretch=(/1.0d0,1.0d0,1.0d0/)
if(associated(np)) then
       call extractDataAttribute(thisnode,"stretch",getstructcrystal%stretch)
       call removeAttribute(thisnode,"stretch")      
endif

      len= countChildEmentsWithName (thisnode,"basevect")           
allocate(getstructcrystal%basevect(len,3))
Do i=1,len

		getstructcrystal%basevect(i,:)=getvalueofbasevect(&
      removechild(thisnode,item(getElementsByTagname(thisnode,&
      "basevect"),0)))
end do

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructspecies(thisnode)

implicit none
type(Node),pointer::thisnode
type(species_type),pointer::getstructspecies
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructspecies)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at species"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"speciesfile")
if(associated(np)) then
       call extractDataAttribute(thisnode,"speciesfile",getstructspecies%speciesfile)
       call removeAttribute(thisnode,"speciesfile")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"chemicalSymbol")
getstructspecies%chemicalSymbol= ""
if(associated(np)) then
       call extractDataAttribute(thisnode,"chemicalSymbol",getstructspecies%chemicalSymbol)
       call removeAttribute(thisnode,"chemicalSymbol")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"atomicNumber")
if(associated(np)) then
       call extractDataAttribute(thisnode,"atomicNumber",getstructspecies%atomicNumber)
       call removeAttribute(thisnode,"atomicNumber")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"rmt")
getstructspecies%rmt=-1
if(associated(np)) then
       call extractDataAttribute(thisnode,"rmt",getstructspecies%rmt)
       call removeAttribute(thisnode,"rmt")      
endif

            len= countChildEmentsWithName(thisnode,"atom")
     
allocate(getstructspecies%atomarray(len))
Do i=0,len-1
getstructspecies%atomarray(i+1)%atom=>getstructatom(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"atom"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"LDAplusu")
getstructspecies%LDAplusu=>null()
Do i=0,len-1
getstructspecies%LDAplusu=>getstructLDAplusu(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"LDAplusu"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructatom(thisnode)

implicit none
type(Node),pointer::thisnode
type(atom_type),pointer::getstructatom
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructatom)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at atom"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"coord")
if(associated(np)) then
       call extractDataAttribute(thisnode,"coord",getstructatom%coord)
       call removeAttribute(thisnode,"coord")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"bfcmt")
getstructatom%bfcmt=(/0,0,0/)
if(associated(np)) then
       call extractDataAttribute(thisnode,"bfcmt",getstructatom%bfcmt)
       call removeAttribute(thisnode,"bfcmt")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructLDAplusu(thisnode)

implicit none
type(Node),pointer::thisnode
type(LDAplusu_type),pointer::getstructLDAplusu
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructLDAplusu)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at LDAplusu"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"L")
getstructLDAplusu%L=0
if(associated(np)) then
       call extractDataAttribute(thisnode,"L",getstructLDAplusu%L)
       call removeAttribute(thisnode,"L")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"U")
getstructLDAplusu%U=0
if(associated(np)) then
       call extractDataAttribute(thisnode,"U",getstructLDAplusu%U)
       call removeAttribute(thisnode,"U")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"J")
getstructLDAplusu%J=0
if(associated(np)) then
       call extractDataAttribute(thisnode,"J",getstructLDAplusu%J)
       call removeAttribute(thisnode,"J")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructgroundstate(thisnode)

implicit none
type(Node),pointer::thisnode
type(groundstate_type),pointer::getstructgroundstate
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructgroundstate)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at groundstate"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"ngkgrid")
if(associated(np)) then
       call extractDataAttribute(thisnode,"ngkgrid",getstructgroundstate%ngkgrid)
       call removeAttribute(thisnode,"ngkgrid")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"rgkmax")
getstructgroundstate%rgkmax=7
if(associated(np)) then
       call extractDataAttribute(thisnode,"rgkmax",getstructgroundstate%rgkmax)
       call removeAttribute(thisnode,"rgkmax")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"epspot")
getstructgroundstate%epspot=1e-6
if(associated(np)) then
       call extractDataAttribute(thisnode,"epspot",getstructgroundstate%epspot)
       call removeAttribute(thisnode,"epspot")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"rmtapm")
getstructgroundstate%rmtapm=(/0.25d0,0.95d0/)
if(associated(np)) then
       call extractDataAttribute(thisnode,"rmtapm",getstructgroundstate%rmtapm)
       call removeAttribute(thisnode,"rmtapm")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"swidth")
getstructgroundstate%swidth=0.01d0
if(associated(np)) then
       call extractDataAttribute(thisnode,"swidth",getstructgroundstate%swidth)
       call removeAttribute(thisnode,"swidth")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"stype")
getstructgroundstate%stype= "Gaussian"
if(associated(np)) then
       call extractDataAttribute(thisnode,"stype",getstructgroundstate%stype)
       call removeAttribute(thisnode,"stype")      
endif
getstructgroundstate%stypenumber=stringtonumberstype(getstructgroundstate%stype)

nullify(np)  
np=>getAttributeNode(thisnode,"isgkmax")
getstructgroundstate%isgkmax=-1
if(associated(np)) then
       call extractDataAttribute(thisnode,"isgkmax",getstructgroundstate%isgkmax)
       call removeAttribute(thisnode,"isgkmax")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"gmaxvr")
getstructgroundstate%gmaxvr=12
if(associated(np)) then
       call extractDataAttribute(thisnode,"gmaxvr",getstructgroundstate%gmaxvr)
       call removeAttribute(thisnode,"gmaxvr")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"nempty")
getstructgroundstate%nempty=5
if(associated(np)) then
       call extractDataAttribute(thisnode,"nempty",getstructgroundstate%nempty)
       call removeAttribute(thisnode,"nempty")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"nosym")
getstructgroundstate%nosym= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"nosym",getstructgroundstate%nosym)
       call removeAttribute(thisnode,"nosym")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"autokpt")
getstructgroundstate%autokpt= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"autokpt",getstructgroundstate%autokpt)
       call removeAttribute(thisnode,"autokpt")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"radkpt")
getstructgroundstate%radkpt=40
if(associated(np)) then
       call extractDataAttribute(thisnode,"radkpt",getstructgroundstate%radkpt)
       call removeAttribute(thisnode,"radkpt")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"reducek")
getstructgroundstate%reducek= .true.
if(associated(np)) then
       call extractDataAttribute(thisnode,"reducek",getstructgroundstate%reducek)
       call removeAttribute(thisnode,"reducek")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"tfibs")
getstructgroundstate%tfibs= .true.
if(associated(np)) then
       call extractDataAttribute(thisnode,"tfibs",getstructgroundstate%tfibs)
       call removeAttribute(thisnode,"tfibs")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"tforce")
getstructgroundstate%tforce= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"tforce",getstructgroundstate%tforce)
       call removeAttribute(thisnode,"tforce")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"lmaxapw")
getstructgroundstate%lmaxapw=8
if(associated(np)) then
       call extractDataAttribute(thisnode,"lmaxapw",getstructgroundstate%lmaxapw)
       call removeAttribute(thisnode,"lmaxapw")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"maxscl")
getstructgroundstate%maxscl=200
if(associated(np)) then
       call extractDataAttribute(thisnode,"maxscl",getstructgroundstate%maxscl)
       call removeAttribute(thisnode,"maxscl")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"chgexs")
getstructgroundstate%chgexs=0
if(associated(np)) then
       call extractDataAttribute(thisnode,"chgexs",getstructgroundstate%chgexs)
       call removeAttribute(thisnode,"chgexs")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"deband")
getstructgroundstate%deband=0.0025d0
if(associated(np)) then
       call extractDataAttribute(thisnode,"deband",getstructgroundstate%deband)
       call removeAttribute(thisnode,"deband")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"epschg")
getstructgroundstate%epschg=1.0d-3
if(associated(np)) then
       call extractDataAttribute(thisnode,"epschg",getstructgroundstate%epschg)
       call removeAttribute(thisnode,"epschg")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"epsocc")
getstructgroundstate%epsocc=1e-8
if(associated(np)) then
       call extractDataAttribute(thisnode,"epsocc",getstructgroundstate%epsocc)
       call removeAttribute(thisnode,"epsocc")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"mixer")
getstructgroundstate%mixer= "lin"
if(associated(np)) then
       call extractDataAttribute(thisnode,"mixer",getstructgroundstate%mixer)
       call removeAttribute(thisnode,"mixer")      
endif
getstructgroundstate%mixernumber=stringtonumbermixer(getstructgroundstate%mixer)

nullify(np)  
np=>getAttributeNode(thisnode,"fromscratch")
getstructgroundstate%fromscratch= .true.
if(associated(np)) then
       call extractDataAttribute(thisnode,"fromscratch",getstructgroundstate%fromscratch)
       call removeAttribute(thisnode,"fromscratch")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"lradstep")
getstructgroundstate%lradstep=4
if(associated(np)) then
       call extractDataAttribute(thisnode,"lradstep",getstructgroundstate%lradstep)
       call removeAttribute(thisnode,"lradstep")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"nprad")
getstructgroundstate%nprad=4
if(associated(np)) then
       call extractDataAttribute(thisnode,"nprad",getstructgroundstate%nprad)
       call removeAttribute(thisnode,"nprad")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"xctype")
getstructgroundstate%xctype= "LSDAPerdew-Wang"
if(associated(np)) then
       call extractDataAttribute(thisnode,"xctype",getstructgroundstate%xctype)
       call removeAttribute(thisnode,"xctype")      
endif
getstructgroundstate%xctypenumber=stringtonumberxctype(getstructgroundstate%xctype)

nullify(np)  
np=>getAttributeNode(thisnode,"evalmin")
getstructgroundstate%evalmin=-4.5d0
if(associated(np)) then
       call extractDataAttribute(thisnode,"evalmin",getstructgroundstate%evalmin)
       call removeAttribute(thisnode,"evalmin")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"lmaxvr")
getstructgroundstate%lmaxvr=7
if(associated(np)) then
       call extractDataAttribute(thisnode,"lmaxvr",getstructgroundstate%lmaxvr)
       call removeAttribute(thisnode,"lmaxvr")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"fracinr")
getstructgroundstate%fracinr=0.25d0
if(associated(np)) then
       call extractDataAttribute(thisnode,"fracinr",getstructgroundstate%fracinr)
       call removeAttribute(thisnode,"fracinr")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"lmaxinr")
getstructgroundstate%lmaxinr=2
if(associated(np)) then
       call extractDataAttribute(thisnode,"lmaxinr",getstructgroundstate%lmaxinr)
       call removeAttribute(thisnode,"lmaxinr")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"lmaxmat")
getstructgroundstate%lmaxmat=5
if(associated(np)) then
       call extractDataAttribute(thisnode,"lmaxmat",getstructgroundstate%lmaxmat)
       call removeAttribute(thisnode,"lmaxmat")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"kdotpgrid")
if(associated(np)) then
       call extractDataAttribute(thisnode,"kdotpgrid",getstructgroundstate%kdotpgrid)
       call removeAttribute(thisnode,"kdotpgrid")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"vkloff")
getstructgroundstate%vkloff=(/0,0,0/)
if(associated(np)) then
       call extractDataAttribute(thisnode,"vkloff",getstructgroundstate%vkloff)
       call removeAttribute(thisnode,"vkloff")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"npsden")
getstructgroundstate%npsden=9
if(associated(np)) then
       call extractDataAttribute(thisnode,"npsden",getstructgroundstate%npsden)
       call removeAttribute(thisnode,"npsden")      
endif

            len= countChildEmentsWithName(thisnode,"spin")
getstructgroundstate%spin=>null()
Do i=0,len-1
getstructgroundstate%spin=>getstructspin(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"spin"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"HartreeFock")
getstructgroundstate%HartreeFock=>null()
Do i=0,len-1
getstructgroundstate%HartreeFock=>getstructHartreeFock(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"HartreeFock"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"solver")
getstructgroundstate%solver=>null()
Do i=0,len-1
getstructgroundstate%solver=>getstructsolver(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"solver"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructspin(thisnode)

implicit none
type(Node),pointer::thisnode
type(spin_type),pointer::getstructspin
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructspin)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at spin"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"bfieldc")
getstructspin%bfieldc=(/0,0,0/)
if(associated(np)) then
       call extractDataAttribute(thisnode,"bfieldc",getstructspin%bfieldc)
       call removeAttribute(thisnode,"bfieldc")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"momfix")
getstructspin%momfix=(/0,0,0/)
if(associated(np)) then
       call extractDataAttribute(thisnode,"momfix",getstructspin%momfix)
       call removeAttribute(thisnode,"momfix")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"spinorb")
if(associated(np)) then
       call extractDataAttribute(thisnode,"spinorb",getstructspin%spinorb)
       call removeAttribute(thisnode,"spinorb")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"spinsprl")
if(associated(np)) then
       call extractDataAttribute(thisnode,"spinsprl",getstructspin%spinsprl)
       call removeAttribute(thisnode,"spinsprl")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"vqlss")
getstructspin%vqlss=(/0,0,0/)
if(associated(np)) then
       call extractDataAttribute(thisnode,"vqlss",getstructspin%vqlss)
       call removeAttribute(thisnode,"vqlss")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"taufsm")
getstructspin%taufsm=0.01d0
if(associated(np)) then
       call extractDataAttribute(thisnode,"taufsm",getstructspin%taufsm)
       call removeAttribute(thisnode,"taufsm")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"reducebf")
getstructspin%reducebf=1
if(associated(np)) then
       call extractDataAttribute(thisnode,"reducebf",getstructspin%reducebf)
       call removeAttribute(thisnode,"reducebf")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"fixspin")
getstructspin%fixspin= "none"
if(associated(np)) then
       call extractDataAttribute(thisnode,"fixspin",getstructspin%fixspin)
       call removeAttribute(thisnode,"fixspin")      
endif
getstructspin%fixspinnumber=stringtonumberfixspin(getstructspin%fixspin)

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructHartreeFock(thisnode)

implicit none
type(Node),pointer::thisnode
type(HartreeFock_type),pointer::getstructHartreeFock
		
integer::len=1,i=0
allocate(getstructHartreeFock)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at HartreeFock"
#endif
      getstructHartreeFock%exists=.false.
      if (associated(thisnode))  getstructHartreeFock%exists=.true.
      
      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructsolver(thisnode)

implicit none
type(Node),pointer::thisnode
type(solver_type),pointer::getstructsolver
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructsolver)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at solver"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"type")
getstructsolver%type= "Lapack"
if(associated(np)) then
       call extractDataAttribute(thisnode,"type",getstructsolver%type)
       call removeAttribute(thisnode,"type")      
endif
getstructsolver%typenumber=stringtonumbertype(getstructsolver%type)

nullify(np)  
np=>getAttributeNode(thisnode,"packedmatrixstorage")
getstructsolver%packedmatrixstorage= .true.
if(associated(np)) then
       call extractDataAttribute(thisnode,"packedmatrixstorage",getstructsolver%packedmatrixstorage)
       call removeAttribute(thisnode,"packedmatrixstorage")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"epsarpack")
if(associated(np)) then
       call extractDataAttribute(thisnode,"epsarpack",getstructsolver%epsarpack)
       call removeAttribute(thisnode,"epsarpack")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructstructureoptimization(thisnode)

implicit none
type(Node),pointer::thisnode
type(structureoptimization_type),pointer::getstructstructureoptimization
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructstructureoptimization)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at structureoptimization"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"epsforce")
getstructstructureoptimization%epsforce=5e-5
if(associated(np)) then
       call extractDataAttribute(thisnode,"epsforce",getstructstructureoptimization%epsforce)
       call removeAttribute(thisnode,"epsforce")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"tau0atm")
getstructstructureoptimization%tau0atm=0.2d0
if(associated(np)) then
       call extractDataAttribute(thisnode,"tau0atm",getstructstructureoptimization%tau0atm)
       call removeAttribute(thisnode,"tau0atm")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"resume")
getstructstructureoptimization%resume= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"resume",getstructstructureoptimization%resume)
       call removeAttribute(thisnode,"resume")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructproperties(thisnode)

implicit none
type(Node),pointer::thisnode
type(properties_type),pointer::getstructproperties
		
integer::len=1,i=0
allocate(getstructproperties)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at properties"
#endif
      
            len= countChildEmentsWithName(thisnode,"bandstructure")
getstructproperties%bandstructure=>null()
Do i=0,len-1
getstructproperties%bandstructure=>getstructbandstructure(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"bandstructure"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"STM")
getstructproperties%STM=>null()
Do i=0,len-1
getstructproperties%STM=>getstructSTM(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"STM"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"wfplot")
getstructproperties%wfplot=>null()
Do i=0,len-1
getstructproperties%wfplot=>getstructwfplot(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"wfplot"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"dos")
getstructproperties%dos=>null()
Do i=0,len-1
getstructproperties%dos=>getstructdos(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"dos"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"LSJ")
getstructproperties%LSJ=>null()
Do i=0,len-1
getstructproperties%LSJ=>getstructLSJ(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"LSJ"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"masstensor")
getstructproperties%masstensor=>null()
Do i=0,len-1
getstructproperties%masstensor=>getstructmasstensor(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"masstensor"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"chargedesityplot")
getstructproperties%chargedesityplot=>null()
Do i=0,len-1
getstructproperties%chargedesityplot=>getstructchargedesityplot(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"chargedesityplot"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"exccplot")
getstructproperties%exccplot=>null()
Do i=0,len-1
getstructproperties%exccplot=>getstructexccplot(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"exccplot"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"elfplot")
getstructproperties%elfplot=>null()
Do i=0,len-1
getstructproperties%elfplot=>getstructelfplot(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"elfplot"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"mvecfield")
getstructproperties%mvecfield=>null()
Do i=0,len-1
getstructproperties%mvecfield=>getstructmvecfield(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"mvecfield"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"xcmvecfield")
getstructproperties%xcmvecfield=>null()
Do i=0,len-1
getstructproperties%xcmvecfield=>getstructxcmvecfield(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"xcmvecfield"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"electricfield")
getstructproperties%electricfield=>null()
Do i=0,len-1
getstructproperties%electricfield=>getstructelectricfield(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"electricfield"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"gradmvecfield")
getstructproperties%gradmvecfield=>null()
Do i=0,len-1
getstructproperties%gradmvecfield=>getstructgradmvecfield(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"gradmvecfield"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"fermisurfaceplot")
getstructproperties%fermisurfaceplot=>null()
Do i=0,len-1
getstructproperties%fermisurfaceplot=>getstructfermisurfaceplot(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"fermisurfaceplot"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"EFG")
getstructproperties%EFG=>null()
Do i=0,len-1
getstructproperties%EFG=>getstructEFG(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"EFG"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"momentummatrix")
getstructproperties%momentummatrix=>null()
Do i=0,len-1
getstructproperties%momentummatrix=>getstructmomentummatrix(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"momentummatrix"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"linresponsetensor")
getstructproperties%linresponsetensor=>null()
Do i=0,len-1
getstructproperties%linresponsetensor=>getstructlinresponsetensor(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"linresponsetensor"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"mossbauer")
getstructproperties%mossbauer=>null()
Do i=0,len-1
getstructproperties%mossbauer=>getstructmossbauer(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"mossbauer"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"dielectric")
getstructproperties%dielectric=>null()
Do i=0,len-1
getstructproperties%dielectric=>getstructdielectric(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"dielectric"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"expiqr")
getstructproperties%expiqr=>null()
Do i=0,len-1
getstructproperties%expiqr=>getstructexpiqr(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"expiqr"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"elnes")
getstructproperties%elnes=>null()
Do i=0,len-1
getstructproperties%elnes=>getstructelnes(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"elnes"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"eliashberg")
getstructproperties%eliashberg=>null()
Do i=0,len-1
getstructproperties%eliashberg=>getstructeliashberg(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"eliashberg"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructbandstructure(thisnode)

implicit none
type(Node),pointer::thisnode
type(bandstructure_type),pointer::getstructbandstructure
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructbandstructure)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at bandstructure"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"scissor")
getstructbandstructure%scissor=0d0
if(associated(np)) then
       call extractDataAttribute(thisnode,"scissor",getstructbandstructure%scissor)
       call removeAttribute(thisnode,"scissor")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"character")
getstructbandstructure%character= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"character",getstructbandstructure%character)
       call removeAttribute(thisnode,"character")      
endif

            len= countChildEmentsWithName(thisnode,"plot1d")
getstructbandstructure%plot1d=>null()
Do i=0,len-1
getstructbandstructure%plot1d=>getstructplot1d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot1d"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructSTM(thisnode)

implicit none
type(Node),pointer::thisnode
type(STM_type),pointer::getstructSTM
		
integer::len=1,i=0
allocate(getstructSTM)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at STM"
#endif
      
            len= countChildEmentsWithName(thisnode,"plot2d")
getstructSTM%plot2d=>null()
Do i=0,len-1
getstructSTM%plot2d=>getstructplot2d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot2d"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructwfplot(thisnode)

implicit none
type(Node),pointer::thisnode
type(wfplot_type),pointer::getstructwfplot
		
integer::len=1,i=0
allocate(getstructwfplot)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at wfplot"
#endif
      
            len= countChildEmentsWithName(thisnode,"kstlist")
getstructwfplot%kstlist=>null()
Do i=0,len-1
getstructwfplot%kstlist=>getstructkstlist(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"kstlist"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot1d")
getstructwfplot%plot1d=>null()
Do i=0,len-1
getstructwfplot%plot1d=>getstructplot1d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot1d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot2d")
getstructwfplot%plot2d=>null()
Do i=0,len-1
getstructwfplot%plot2d=>getstructplot2d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot2d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot3d")
getstructwfplot%plot3d=>null()
Do i=0,len-1
getstructwfplot%plot3d=>getstructplot3d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot3d"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructdos(thisnode)

implicit none
type(Node),pointer::thisnode
type(dos_type),pointer::getstructdos
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructdos)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at dos"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"lmirep")
getstructdos%lmirep= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"lmirep",getstructdos%lmirep)
       call removeAttribute(thisnode,"lmirep")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"nwdos")
getstructdos%nwdos=500
if(associated(np)) then
       call extractDataAttribute(thisnode,"nwdos",getstructdos%nwdos)
       call removeAttribute(thisnode,"nwdos")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"ngrdos")
getstructdos%ngrdos=100
if(associated(np)) then
       call extractDataAttribute(thisnode,"ngrdos",getstructdos%ngrdos)
       call removeAttribute(thisnode,"ngrdos")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"scissor")
if(associated(np)) then
       call extractDataAttribute(thisnode,"scissor",getstructdos%scissor)
       call removeAttribute(thisnode,"scissor")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"nsmdos")
getstructdos%nsmdos=0
if(associated(np)) then
       call extractDataAttribute(thisnode,"nsmdos",getstructdos%nsmdos)
       call removeAttribute(thisnode,"nsmdos")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"wintdos")
getstructdos%wintdos=(/.5,.5/)
if(associated(np)) then
       call extractDataAttribute(thisnode,"wintdos",getstructdos%wintdos)
       call removeAttribute(thisnode,"wintdos")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructLSJ(thisnode)

implicit none
type(Node),pointer::thisnode
type(LSJ_type),pointer::getstructLSJ
		
integer::len=1,i=0
allocate(getstructLSJ)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at LSJ"
#endif
      
            len= countChildEmentsWithName(thisnode,"kstlist")
getstructLSJ%kstlist=>null()
Do i=0,len-1
getstructLSJ%kstlist=>getstructkstlist(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"kstlist"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructmasstensor(thisnode)

implicit none
type(Node),pointer::thisnode
type(masstensor_type),pointer::getstructmasstensor
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructmasstensor)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at masstensor"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"deltaem")
getstructmasstensor%deltaem=0.025d0
if(associated(np)) then
       call extractDataAttribute(thisnode,"deltaem",getstructmasstensor%deltaem)
       call removeAttribute(thisnode,"deltaem")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"ndspem")
getstructmasstensor%ndspem=1
if(associated(np)) then
       call extractDataAttribute(thisnode,"ndspem",getstructmasstensor%ndspem)
       call removeAttribute(thisnode,"ndspem")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"vklem")
getstructmasstensor%vklem=(/0,0,0/)
if(associated(np)) then
       call extractDataAttribute(thisnode,"vklem",getstructmasstensor%vklem)
       call removeAttribute(thisnode,"vklem")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructchargedesityplot(thisnode)

implicit none
type(Node),pointer::thisnode
type(chargedesityplot_type),pointer::getstructchargedesityplot
		
integer::len=1,i=0
allocate(getstructchargedesityplot)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at chargedesityplot"
#endif
      
            len= countChildEmentsWithName(thisnode,"plot1d")
getstructchargedesityplot%plot1d=>null()
Do i=0,len-1
getstructchargedesityplot%plot1d=>getstructplot1d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot1d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot2d")
getstructchargedesityplot%plot2d=>null()
Do i=0,len-1
getstructchargedesityplot%plot2d=>getstructplot2d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot2d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot3d")
getstructchargedesityplot%plot3d=>null()
Do i=0,len-1
getstructchargedesityplot%plot3d=>getstructplot3d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot3d"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructexccplot(thisnode)

implicit none
type(Node),pointer::thisnode
type(exccplot_type),pointer::getstructexccplot
		
integer::len=1,i=0
allocate(getstructexccplot)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at exccplot"
#endif
      
            len= countChildEmentsWithName(thisnode,"plot1d")
getstructexccplot%plot1d=>null()
Do i=0,len-1
getstructexccplot%plot1d=>getstructplot1d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot1d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot2d")
getstructexccplot%plot2d=>null()
Do i=0,len-1
getstructexccplot%plot2d=>getstructplot2d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot2d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot3d")
getstructexccplot%plot3d=>null()
Do i=0,len-1
getstructexccplot%plot3d=>getstructplot3d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot3d"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructelfplot(thisnode)

implicit none
type(Node),pointer::thisnode
type(elfplot_type),pointer::getstructelfplot
		
integer::len=1,i=0
allocate(getstructelfplot)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at elfplot"
#endif
      
            len= countChildEmentsWithName(thisnode,"plot1d")
getstructelfplot%plot1d=>null()
Do i=0,len-1
getstructelfplot%plot1d=>getstructplot1d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot1d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot2d")
getstructelfplot%plot2d=>null()
Do i=0,len-1
getstructelfplot%plot2d=>getstructplot2d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot2d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot3d")
getstructelfplot%plot3d=>null()
Do i=0,len-1
getstructelfplot%plot3d=>getstructplot3d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot3d"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructmvecfield(thisnode)

implicit none
type(Node),pointer::thisnode
type(mvecfield_type),pointer::getstructmvecfield
		
integer::len=1,i=0
allocate(getstructmvecfield)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at mvecfield"
#endif
      
            len= countChildEmentsWithName(thisnode,"plot2d")
getstructmvecfield%plot2d=>null()
Do i=0,len-1
getstructmvecfield%plot2d=>getstructplot2d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot2d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot3d")
getstructmvecfield%plot3d=>null()
Do i=0,len-1
getstructmvecfield%plot3d=>getstructplot3d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot3d"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructxcmvecfield(thisnode)

implicit none
type(Node),pointer::thisnode
type(xcmvecfield_type),pointer::getstructxcmvecfield
		
integer::len=1,i=0
allocate(getstructxcmvecfield)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at xcmvecfield"
#endif
      
            len= countChildEmentsWithName(thisnode,"plot2d")
getstructxcmvecfield%plot2d=>null()
Do i=0,len-1
getstructxcmvecfield%plot2d=>getstructplot2d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot2d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot3d")
getstructxcmvecfield%plot3d=>null()
Do i=0,len-1
getstructxcmvecfield%plot3d=>getstructplot3d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot3d"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructelectricfield(thisnode)

implicit none
type(Node),pointer::thisnode
type(electricfield_type),pointer::getstructelectricfield
		
integer::len=1,i=0
allocate(getstructelectricfield)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at electricfield"
#endif
      
            len= countChildEmentsWithName(thisnode,"plot2d")
getstructelectricfield%plot2d=>null()
Do i=0,len-1
getstructelectricfield%plot2d=>getstructplot2d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot2d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot3d")
getstructelectricfield%plot3d=>null()
Do i=0,len-1
getstructelectricfield%plot3d=>getstructplot3d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot3d"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructgradmvecfield(thisnode)

implicit none
type(Node),pointer::thisnode
type(gradmvecfield_type),pointer::getstructgradmvecfield
		
integer::len=1,i=0
allocate(getstructgradmvecfield)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at gradmvecfield"
#endif
      
            len= countChildEmentsWithName(thisnode,"plot1d")
getstructgradmvecfield%plot1d=>null()
Do i=0,len-1
getstructgradmvecfield%plot1d=>getstructplot1d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot1d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot2d")
getstructgradmvecfield%plot2d=>null()
Do i=0,len-1
getstructgradmvecfield%plot2d=>getstructplot2d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot2d"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plot3d")
getstructgradmvecfield%plot3d=>null()
Do i=0,len-1
getstructgradmvecfield%plot3d=>getstructplot3d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot3d"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructfermisurfaceplot(thisnode)

implicit none
type(Node),pointer::thisnode
type(fermisurfaceplot_type),pointer::getstructfermisurfaceplot
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructfermisurfaceplot)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at fermisurfaceplot"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"nstfsp")
getstructfermisurfaceplot%nstfsp=6
if(associated(np)) then
       call extractDataAttribute(thisnode,"nstfsp",getstructfermisurfaceplot%nstfsp)
       call removeAttribute(thisnode,"nstfsp")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"separate")
if(associated(np)) then
       call extractDataAttribute(thisnode,"separate",getstructfermisurfaceplot%separate)
       call removeAttribute(thisnode,"separate")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructEFG(thisnode)

implicit none
type(Node),pointer::thisnode
type(EFG_type),pointer::getstructEFG
		
integer::len=1,i=0
allocate(getstructEFG)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at EFG"
#endif
      
      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructmomentummatrix(thisnode)

implicit none
type(Node),pointer::thisnode
type(momentummatrix_type),pointer::getstructmomentummatrix
		
integer::len=1,i=0
allocate(getstructmomentummatrix)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at momentummatrix"
#endif
      
      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructlinresponsetensor(thisnode)

implicit none
type(Node),pointer::thisnode
type(linresponsetensor_type),pointer::getstructlinresponsetensor
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructlinresponsetensor)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at linresponsetensor"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"scissor")
if(associated(np)) then
       call extractDataAttribute(thisnode,"scissor",getstructlinresponsetensor%scissor)
       call removeAttribute(thisnode,"scissor")      
endif

      len= countChildEmentsWithName (thisnode,"optcomp")           
allocate(getstructlinresponsetensor%optcomp(len,3))
Do i=1,len

		getstructlinresponsetensor%optcomp(i,:)=getvalueofoptcomp(&
      removechild(thisnode,item(getElementsByTagname(thisnode,&
      "optcomp"),0)))
end do

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructmossbauer(thisnode)

implicit none
type(Node),pointer::thisnode
type(mossbauer_type),pointer::getstructmossbauer
		
integer::len=1,i=0
allocate(getstructmossbauer)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at mossbauer"
#endif
      
      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructdielectric(thisnode)

implicit none
type(Node),pointer::thisnode
type(dielectric_type),pointer::getstructdielectric
		
integer::len=1,i=0
allocate(getstructdielectric)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at dielectric"
#endif
      
      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructexpiqr(thisnode)

implicit none
type(Node),pointer::thisnode
type(expiqr_type),pointer::getstructexpiqr
		
integer::len=1,i=0
allocate(getstructexpiqr)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at expiqr"
#endif
      
      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructelnes(thisnode)

implicit none
type(Node),pointer::thisnode
type(elnes_type),pointer::getstructelnes
		
integer::len=1,i=0
allocate(getstructelnes)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at elnes"
#endif
      
      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructeliashberg(thisnode)

implicit none
type(Node),pointer::thisnode
type(eliashberg_type),pointer::getstructeliashberg
		
integer::len=1,i=0
allocate(getstructeliashberg)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at eliashberg"
#endif
      
      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructphonons(thisnode)

implicit none
type(Node),pointer::thisnode
type(phonons_type),pointer::getstructphonons
		
integer::len=1,i=0
allocate(getstructphonons)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at phonons"
#endif
      
            len= countChildEmentsWithName(thisnode,"qpointset")
getstructphonons%qpointset=>null()
Do i=0,len-1
getstructphonons%qpointset=>getstructqpointset(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"qpointset"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"phonondos")
getstructphonons%phonondos=>null()
Do i=0,len-1
getstructphonons%phonondos=>getstructphonondos(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"phonondos"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"phonondispplot")
getstructphonons%phonondispplot=>null()
Do i=0,len-1
getstructphonons%phonondispplot=>getstructphonondispplot(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"phonondispplot"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructphonondos(thisnode)

implicit none
type(Node),pointer::thisnode
type(phonondos_type),pointer::getstructphonondos
		
integer::len=1,i=0
allocate(getstructphonondos)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at phonondos"
#endif
      
      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructphonondispplot(thisnode)

implicit none
type(Node),pointer::thisnode
type(phonondispplot_type),pointer::getstructphonondispplot
		
integer::len=1,i=0
allocate(getstructphonondispplot)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at phonondispplot"
#endif
      
            len= countChildEmentsWithName(thisnode,"plot1d")
getstructphonondispplot%plot1d=>null()
Do i=0,len-1
getstructphonondispplot%plot1d=>getstructplot1d(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plot1d"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructxs(thisnode)

implicit none
type(Node),pointer::thisnode
type(xs_type),pointer::getstructxs
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructxs)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at xs"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"ngridk")
if(associated(np)) then
       call extractDataAttribute(thisnode,"ngridk",getstructxs%ngridk)
       call removeAttribute(thisnode,"ngridk")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"vkloff")
getstructxs%vkloff=(/0,0,0/)
if(associated(np)) then
       call extractDataAttribute(thisnode,"vkloff",getstructxs%vkloff)
       call removeAttribute(thisnode,"vkloff")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"reducek")
getstructxs%reducek= .true.
if(associated(np)) then
       call extractDataAttribute(thisnode,"reducek",getstructxs%reducek)
       call removeAttribute(thisnode,"reducek")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"ngridq")
if(associated(np)) then
       call extractDataAttribute(thisnode,"ngridq",getstructxs%ngridq)
       call removeAttribute(thisnode,"ngridq")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"nosym")
getstructxs%nosym= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"nosym",getstructxs%nosym)
       call removeAttribute(thisnode,"nosym")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"gqmax")
getstructxs%gqmax=0
if(associated(np)) then
       call extractDataAttribute(thisnode,"gqmax",getstructxs%gqmax)
       call removeAttribute(thisnode,"gqmax")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"rgkmax")
getstructxs%rgkmax=7
if(associated(np)) then
       call extractDataAttribute(thisnode,"rgkmax",getstructxs%rgkmax)
       call removeAttribute(thisnode,"rgkmax")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"lmaxapw")
getstructxs%lmaxapw=8
if(associated(np)) then
       call extractDataAttribute(thisnode,"lmaxapw",getstructxs%lmaxapw)
       call removeAttribute(thisnode,"lmaxapw")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"nempty")
getstructxs%nempty=5
if(associated(np)) then
       call extractDataAttribute(thisnode,"nempty",getstructxs%nempty)
       call removeAttribute(thisnode,"nempty")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"xstype")
getstructxs%xstype= "TDDFT"
if(associated(np)) then
       call extractDataAttribute(thisnode,"xstype",getstructxs%xstype)
       call removeAttribute(thisnode,"xstype")      
endif
getstructxs%xstypenumber=stringtonumberxstype(getstructxs%xstype)

            len= countChildEmentsWithName(thisnode,"tddft")
getstructxs%tddft=>null()
Do i=0,len-1
getstructxs%tddft=>getstructtddft(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"tddft"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"BSE")
getstructxs%BSE=>null()
Do i=0,len-1
getstructxs%BSE=>getstructBSE(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"BSE"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"qpointset")
getstructxs%qpointset=>null()
Do i=0,len-1
getstructxs%qpointset=>getstructqpointset(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"qpointset"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"plan")
getstructxs%plan=>null()
Do i=0,len-1
getstructxs%plan=>getstructplan(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"plan"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"tetra")
getstructxs%tetra=>null()
Do i=0,len-1
getstructxs%tetra=>getstructtetra(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"tetra"),0)) ) 
enddo

            len= countChildEmentsWithName(thisnode,"dosWindow")
getstructxs%dosWindow=>null()
Do i=0,len-1
getstructxs%dosWindow=>getstructdosWindow(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"dosWindow"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructtddft(thisnode)

implicit none
type(Node),pointer::thisnode
type(tddft_type),pointer::getstructtddft
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructtddft)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at tddft"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"dfoffdiag")
getstructtddft%dfoffdiag= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"dfoffdiag",getstructtddft%dfoffdiag)
       call removeAttribute(thisnode,"dfoffdiag")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"emattype")
getstructtddft%emattype=0
if(associated(np)) then
       call extractDataAttribute(thisnode,"emattype",getstructtddft%emattype)
       call removeAttribute(thisnode,"emattype")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"lmaxapwwf")
getstructtddft%lmaxapwwf=-1
if(associated(np)) then
       call extractDataAttribute(thisnode,"lmaxapwwf",getstructtddft%lmaxapwwf)
       call removeAttribute(thisnode,"lmaxapwwf")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"lmaxemat")
getstructtddft%lmaxemat=3
if(associated(np)) then
       call extractDataAttribute(thisnode,"lmaxemat",getstructtddft%lmaxemat)
       call removeAttribute(thisnode,"lmaxemat")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"scissor")
getstructtddft%scissor=0
if(associated(np)) then
       call extractDataAttribute(thisnode,"scissor",getstructtddft%scissor)
       call removeAttribute(thisnode,"scissor")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"optswidth")
getstructtddft%optswidth=0
if(associated(np)) then
       call extractDataAttribute(thisnode,"optswidth",getstructtddft%optswidth)
       call removeAttribute(thisnode,"optswidth")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"intraband")
getstructtddft%intraband= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"intraband",getstructtddft%intraband)
       call removeAttribute(thisnode,"intraband")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"tetradf")
getstructtddft%tetradf= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"tetradf",getstructtddft%tetradf)
       call removeAttribute(thisnode,"tetradf")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"torddf")
getstructtddft%torddf= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"torddf",getstructtddft%torddf)
       call removeAttribute(thisnode,"torddf")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"acont")
getstructtddft%acont= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"acont",getstructtddft%acont)
       call removeAttribute(thisnode,"acont")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"nwacont")
getstructtddft%nwacont=0
if(associated(np)) then
       call extractDataAttribute(thisnode,"nwacont",getstructtddft%nwacont)
       call removeAttribute(thisnode,"nwacont")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"broad")
getstructtddft%broad=0.01d0
if(associated(np)) then
       call extractDataAttribute(thisnode,"broad",getstructtddft%broad)
       call removeAttribute(thisnode,"broad")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"lindhard")
getstructtddft%lindhard= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"lindhard",getstructtddft%lindhard)
       call removeAttribute(thisnode,"lindhard")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"aresdf")
getstructtddft%aresdf= .true.
if(associated(np)) then
       call extractDataAttribute(thisnode,"aresdf",getstructtddft%aresdf)
       call removeAttribute(thisnode,"aresdf")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"epsdfde")
getstructtddft%epsdfde=1.0d-8
if(associated(np)) then
       call extractDataAttribute(thisnode,"epsdfde",getstructtddft%epsdfde)
       call removeAttribute(thisnode,"epsdfde")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"emaxdf")
getstructtddft%emaxdf=1d10
if(associated(np)) then
       call extractDataAttribute(thisnode,"emaxdf",getstructtddft%emaxdf)
       call removeAttribute(thisnode,"emaxdf")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"fxctype")
getstructtddft%fxctype= "0"
if(associated(np)) then
       call extractDataAttribute(thisnode,"fxctype",getstructtddft%fxctype)
       call removeAttribute(thisnode,"fxctype")      
endif
getstructtddft%fxctypenumber=stringtonumberfxctype(getstructtddft%fxctype)

nullify(np)  
np=>getAttributeNode(thisnode,"kerndiag")
getstructtddft%kerndiag= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"kerndiag",getstructtddft%kerndiag)
       call removeAttribute(thisnode,"kerndiag")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"lmaxalda")
getstructtddft%lmaxalda=3
if(associated(np)) then
       call extractDataAttribute(thisnode,"lmaxalda",getstructtddft%lmaxalda)
       call removeAttribute(thisnode,"lmaxalda")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"alphalrc")
getstructtddft%alphalrc=0
if(associated(np)) then
       call extractDataAttribute(thisnode,"alphalrc",getstructtddft%alphalrc)
       call removeAttribute(thisnode,"alphalrc")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"alphalrcdyn")
getstructtddft%alphalrcdyn=0
if(associated(np)) then
       call extractDataAttribute(thisnode,"alphalrcdyn",getstructtddft%alphalrcdyn)
       call removeAttribute(thisnode,"alphalrcdyn")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"betalrcdyn")
if(associated(np)) then
       call extractDataAttribute(thisnode,"betalrcdyn",getstructtddft%betalrcdyn)
       call removeAttribute(thisnode,"betalrcdyn")      
endif

            len= countChildEmentsWithName(thisnode,"dftrans")
getstructtddft%dftrans=>null()
Do i=0,len-1
getstructtddft%dftrans=>getstructdftrans(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"dftrans"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructdftrans(thisnode)

implicit none
type(Node),pointer::thisnode
type(dftrans_type),pointer::getstructdftrans
		
integer::len=1,i=0
allocate(getstructdftrans)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at dftrans"
#endif
      
      len= countChildEmentsWithName (thisnode,"trans")           
allocate(getstructdftrans%trans(len,3))
Do i=1,len

		getstructdftrans%trans(i,:)=getvalueoftrans(&
      removechild(thisnode,item(getElementsByTagname(thisnode,&
      "trans"),0)))
end do

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructBSE(thisnode)

implicit none
type(Node),pointer::thisnode
type(BSE_type),pointer::getstructBSE
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructBSE)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at BSE"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"tordfxc")
getstructBSE%tordfxc= "causal"
if(associated(np)) then
       call extractDataAttribute(thisnode,"tordfxc",getstructBSE%tordfxc)
       call removeAttribute(thisnode,"tordfxc")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"aresfxc")
getstructBSE%aresfxc= .true.
if(associated(np)) then
       call extractDataAttribute(thisnode,"aresfxc",getstructBSE%aresfxc)
       call removeAttribute(thisnode,"aresfxc")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"fxcbsesplit")
getstructBSE%fxcbsesplit=1d-5
if(associated(np)) then
       call extractDataAttribute(thisnode,"fxcbsesplit",getstructBSE%fxcbsesplit)
       call removeAttribute(thisnode,"fxcbsesplit")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"lmaxdielt")
getstructBSE%lmaxdielt=14
if(associated(np)) then
       call extractDataAttribute(thisnode,"lmaxdielt",getstructBSE%lmaxdielt)
       call removeAttribute(thisnode,"lmaxdielt")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"nleblaik")
getstructBSE%nleblaik=5810
if(associated(np)) then
       call extractDataAttribute(thisnode,"nleblaik",getstructBSE%nleblaik)
       call removeAttribute(thisnode,"nleblaik")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"nexcitmax")
getstructBSE%nexcitmax=100
if(associated(np)) then
       call extractDataAttribute(thisnode,"nexcitmax",getstructBSE%nexcitmax)
       call removeAttribute(thisnode,"nexcitmax")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructplan(thisnode)

implicit none
type(Node),pointer::thisnode
type(plan_type),pointer::getstructplan
		
integer::len=1,i=0
allocate(getstructplan)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at plan"
#endif
      
            len= countChildEmentsWithName(thisnode,"doonly")
     
allocate(getstructplan%doonlyarray(len))
Do i=0,len-1
getstructplan%doonlyarray(i+1)%doonly=>getstructdoonly(&
removeChild(thisnode,item(getElementsByTagname(thisnode,&
"doonly"),0)) ) 
enddo

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructdoonly(thisnode)

implicit none
type(Node),pointer::thisnode
type(doonly_type),pointer::getstructdoonly
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructdoonly)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at doonly"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"task")
if(associated(np)) then
       call extractDataAttribute(thisnode,"task",getstructdoonly%task)
       call removeAttribute(thisnode,"task")      
endif
getstructdoonly%tasknumber=stringtonumbertask(getstructdoonly%task)

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructtetra(thisnode)

implicit none
type(Node),pointer::thisnode
type(tetra_type),pointer::getstructtetra
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructtetra)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at tetra"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"kordexc")
getstructtetra%kordexc= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"kordexc",getstructtetra%kordexc)
       call removeAttribute(thisnode,"kordexc")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"cw1k")
getstructtetra%cw1k= .false.
if(associated(np)) then
       call extractDataAttribute(thisnode,"cw1k",getstructtetra%cw1k)
       call removeAttribute(thisnode,"cw1k")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"qweights")
getstructtetra%qweights=1
if(associated(np)) then
       call extractDataAttribute(thisnode,"qweights",getstructtetra%qweights)
       call removeAttribute(thisnode,"qweights")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructdosWindow(thisnode)

implicit none
type(Node),pointer::thisnode
type(dosWindow_type),pointer::getstructdosWindow
		type(Node),pointer::np


integer::len=1,i=0
allocate(getstructdosWindow)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at dosWindow"
#endif
      
nullify(np)  
np=>getAttributeNode(thisnode,"points")
getstructdosWindow%points=500
if(associated(np)) then
       call extractDataAttribute(thisnode,"points",getstructdosWindow%points)
       call removeAttribute(thisnode,"points")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"emin")
getstructdosWindow%emin=-0.5
if(associated(np)) then
       call extractDataAttribute(thisnode,"emin",getstructdosWindow%emin)
       call removeAttribute(thisnode,"emin")      
endif

nullify(np)  
np=>getAttributeNode(thisnode,"emax")
getstructdosWindow%emax=0.5
if(associated(np)) then
       call extractDataAttribute(thisnode,"emax",getstructdosWindow%emax)
       call removeAttribute(thisnode,"emax")      
endif

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function

function getstructqpointset(thisnode)

implicit none
type(Node),pointer::thisnode
type(qpointset_type),pointer::getstructqpointset
		
integer::len=1,i=0
allocate(getstructqpointset)  
#ifdef INPUTDEBUG      
      write(*,*)"we are at qpointset"
#endif
      
      len= countChildEmentsWithName (thisnode,"qpoint")           
allocate(getstructqpointset%qpoint(len,3))
Do i=1,len

		getstructqpointset%qpoint(i,:)=getvalueofqpoint(&
      removechild(thisnode,item(getElementsByTagname(thisnode,&
      "qpoint"),0)))
end do

      i=0
      len=0
      call  handleunknownnodes(thisnode)
end function
 
function getvalueofpointstatepair(thisnode)
implicit none
type(Node),pointer::thisnode
 integer::getvalueofpointstatepair(2)

#ifdef INPUTDEBUG
  write(*,*)"we are at pointstatepair"
#endif  
   call extractDataContent(thisnode,  getvalueofpointstatepair)
end function 
function getvalueoftitle(thisnode)
implicit none
type(Node),pointer::thisnode
 character(512)::getvalueoftitle

#ifdef INPUTDEBUG
  write(*,*)"we are at title"
#endif  
   call extractDataContent(thisnode,  getvalueoftitle)
end function 
function getvalueofbasevect(thisnode)
implicit none
type(Node),pointer::thisnode
 real(8)::getvalueofbasevect(3)

#ifdef INPUTDEBUG
  write(*,*)"we are at basevect"
#endif  
   call extractDataContent(thisnode,  getvalueofbasevect)
end function 
function getvalueofoptcomp(thisnode)
implicit none
type(Node),pointer::thisnode
 integer::getvalueofoptcomp(3)

#ifdef INPUTDEBUG
  write(*,*)"we are at optcomp"
#endif  
   call extractDataContent(thisnode,  getvalueofoptcomp)
end function 
function getvalueoftrans(thisnode)
implicit none
type(Node),pointer::thisnode
 integer::getvalueoftrans(3)

#ifdef INPUTDEBUG
  write(*,*)"we are at trans"
#endif  
   call extractDataContent(thisnode,  getvalueoftrans)
end function 
function getvalueofqpoint(thisnode)
implicit none
type(Node),pointer::thisnode
 real(8)::getvalueofqpoint(3)

#ifdef INPUTDEBUG
  write(*,*)"we are at qpoint"
#endif  
   call extractDataContent(thisnode,  getvalueofqpoint)
end function
 integer function  stringtonumberfixspin(string) 
 character(80),intent(in)::string
 select case(trim(adjustl(string)))
case('none')
 stringtonumberfixspin=0
case('total FSM')
 stringtonumberfixspin=1
case('localmt FSM')
 stringtonumberfixspin=2
case('both')
 stringtonumberfixspin=3
case('')
 stringtonumberfixspin=0
case default
write(*,*) "'", string,"' is not valid selection forfixspin "
stop 
end select
end function

 
 integer function  stringtonumbertype(string) 
 character(80),intent(in)::string
 select case(trim(adjustl(string)))
case('Lapack')
 stringtonumbertype=1
case('Arpack')
 stringtonumbertype=2
case('DIIS')
 stringtonumbertype=3
case('')
 stringtonumbertype=0
case default
write(*,*) "'", string,"' is not valid selection fortype "
stop 
end select
end function

 
 integer function  stringtonumberstype(string) 
 character(80),intent(in)::string
 select case(trim(adjustl(string)))
case('Gaussian')
 stringtonumberstype=0
case('Methfessel-Paxton 1')
 stringtonumberstype=1
case('Methfessel-Paxton 2')
 stringtonumberstype=2
case('Fermi Dirac')
 stringtonumberstype=3
case('')
 stringtonumberstype=0
case default
write(*,*) "'", string,"' is not valid selection forstype "
stop 
end select
end function

 
 integer function  stringtonumbermixer(string) 
 character(80),intent(in)::string
 select case(trim(adjustl(string)))
case('lin')
 stringtonumbermixer=1
case('msec')
 stringtonumbermixer=2
case('pulay')
 stringtonumbermixer=3
case('')
 stringtonumbermixer=0
case default
write(*,*) "'", string,"' is not valid selection formixer "
stop 
end select
end function

 
 integer function  stringtonumberxctype(string) 
 character(80),intent(in)::string
 select case(trim(adjustl(string)))
case('LDAPerdew-Zunger')
 stringtonumberxctype=2
case('LSDAPerdew-Wang')
 stringtonumberxctype=3
case('LDA-X-alpha')
 stringtonumberxctype=4
case('LSDA-Barth-Hedin')
 stringtonumberxctype=5
case('GGAPerdew-Burke-Ernzerhof')
 stringtonumberxctype=20
case('GGArevPBE')
 stringtonumberxctype=21
case('GGAPBEsol')
 stringtonumberxctype=22
case('GGA-Wu-Cohen')
 stringtonumberxctype=26
case('GGAArmiento-Mattsson')
 stringtonumberxctype=30
case('EXX')
 stringtonumberxctype=-1
case('none')
 stringtonumberxctype=0
case('')
 stringtonumberxctype=0
case default
write(*,*) "'", string,"' is not valid selection forxctype "
stop 
end select
end function

 
 integer function  stringtonumberfxctype(string) 
 character(80),intent(in)::string
 select case(trim(adjustl(string)))
case('0')
 stringtonumberfxctype=0
case('1')
 stringtonumberfxctype=1
case('2')
 stringtonumberfxctype=2
case('3')
 stringtonumberfxctype=3
case('4')
 stringtonumberfxctype=4
case('5')
 stringtonumberfxctype=5
case('7')
 stringtonumberfxctype=7
case('8')
 stringtonumberfxctype=8
case('')
 stringtonumberfxctype=0
case default
write(*,*) "'", string,"' is not valid selection forfxctype "
stop 
end select
end function

 
 integer function  stringtonumbertask(string) 
 character(80),intent(in)::string
 select case(trim(adjustl(string)))
case('xsgeneigvrc')
 stringtonumbertask=301
case('writepmatxs')
 stringtonumbertask=320
case('writeeemat')
 stringtonumbertask=330
case('tetcalccw')
 stringtonumbertask=310
case('df')
 stringtonumbertask=340
case('idf')
 stringtonumbertask=350
case('scrgeneigvec')
 stringtonumbertask=401
case('screen')
 stringtonumbertask=430
case('scrcoulint')
 stringtonumbertask=440
case('kernxc_bse')
 stringtonumbertask=450
case('scrwritepmat')
 stringtonumbertask=420
case('scrtetcalccw')
 stringtonumbertask=410
case('exccoulint')
 stringtonumbertask=441
case('')
 stringtonumbertask=0
case default
write(*,*) "'", string,"' is not valid selection fortask "
stop 
end select
end function

 
 integer function  stringtonumberxstype(string) 
 character(80),intent(in)::string
 select case(trim(adjustl(string)))
case('TDDFT')
 stringtonumberxstype=-1
case('BSE')
 stringtonumberxstype=-1
case('')
 stringtonumberxstype=0
case default
write(*,*) "'", string,"' is not valid selection forxstype "
stop 
end select
end function

 

function countChildEmentsWithName(nodep,name)
implicit none
integer::countChildEmentsWithName
type(Node),pointer,intent(in) ::nodep
character(len=*),intent(in)::name
type(NodeList),pointer::children

integer::i
children=>getChildNodes(nodep)
countChildEmentsWithName=0
do i=1,getlength(children)
if(name.eq.getNodeName(item(children,i-1))) countChildEmentsWithName=countChildEmentsWithName+1
end do

end function  
    
! this are some transient helper functions to simplify the port (schouldnt be used)
function isspinorb()
logical::isspinorb
isspinorb=.false.
if(associated(input%groundstate%spin))then
if (input%groundstate%spin%spinorb) then
isspinorb=.true.
endif
endif
end function
function isspinspiral() 
logical::isspinspiral
isspinspiral=.false.
if(associated(input%groundstate%spin))then
if (input%groundstate%spin%spinsprl) then
isspinspiral=.true.
endif
endif
end function

function getfixspinnumber()
implicit none
integer::getfixspinnumber
getfixspinnumber=0
if(associated(input%groundstate%spin))then
getfixspinnumber=input%groundstate%spin%fixspinnumber
endif
end function


end module

