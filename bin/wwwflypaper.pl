#!/usr/bin/perl
#
# wwwflypaper.pl -- Generate a real-looking bogus web page
#
#       Copyright (C) 2005-2007 Jari Aalto
#       Created:      2005-09
#       Keywords:     Perl, HTML, fake web page
#
#       This program is free software; you can redistribute it and/or
#       modify it under the terms of the GNU General Public License as
#       published by the Free Software Foundation; either version 2 of
#       the License, or (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful, but
#       WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#       General Public License for more details.
#       Visit <http://www.gnu.org/copyleft/gpl.html>.
#
#   Introduction
#
#       Please start this program with option
#
#           --help      to get the help page
#
#   Profiling results
#
#       Here are Devel::Dprof profiling results from 500Mhz/60G/ATA66/ext2
#       Time in seconds is User time.
#
#           perl -d:DProf ./wwwflypaper.pl > /dev/null
#           dprofpp
#
#       Total Elapsed Time = 0.063201 Seconds
#         User+System Time = 0.063201 Seconds
#       Exclusive Times
#       %Time ExclSec CumulS #Calls sec/call Csec/c  Name
#        31.6   0.020  0.030      3   0.0066 0.0100  main::BEGIN
#        28.4   0.018  0.018    374   0.0000 0.0000  main::GetWord
#        15.8   0.010  0.010      2   0.0050 0.0050  autouse::BEGIN
#        11.0   0.007  0.023      1   0.0068 0.0233  main::Main
#        0.00       - -0.000      1        -      -  warnings::unimport
#        0.00       - -0.000      1        -      -  strict::bits
#        0.00       - -0.000      1        -      -  strict::import
#        0.00       - -0.000      1        -      -  warnings::BEGIN
#        0.00       - -0.000      2        -      -  autouse::import
#        0.00       - -0.000      1        -      -  main::AddLinks
#           -       - -0.001    179        -      -  main::GetLetter
#
# Debian:
#
#  cp fakemail.pl /usr/lib/cgi-bin/

use strict;

use autouse 'Pod::Text' => qw( pod2text );
use autouse 'Pod::Html' => qw( pod2html );

#  Do not modify these values.

my $FILE_ID   = '$Id: wwwflypaper.pl,v 1.4 2006/06/10 20:20:51 jaalto Exp $'; #font '
my $VERSION   = (split ' ', $FILE_ID)[2];

my $DOCTYPE   = qq(<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">);
my $CHARSET   = "charset=iso-8859-1";

#  This can be changed from command line.

my $ROOTDIR   = "/email";

#  Two random words make the "list name"

my @titles = qw
(
    academic
    blue
    center
    chess
    corporate
    devel
    education
    fitness
    game
    health
    master
    radiology
    research
    team
    top
);

#  Additional Domain names to make the address "look real"

my @dname = qw
(
    advertise
    animal
    apartment
    big
    condo
    eye
    family
    freetime
    health
    home
    house
    instant
    leisure
    money
    parents
    people
    wow
);

#  See http://www.iana.org/gtld/gtld.htm

my @tld = qw
(
    biz
    com
    coop
    edu
    gov
    info
    int
    mil
    museum
    name
    net
    org
    pro
    travel
);

# See ISO 3166 country code standard
# GOOGLE: country codes ISO 3166 site:iso.org

my @countries = qw
(
    af
    ax
    al
    dz
    as
    ad
    ao
    ai
    aq
    ag
    ar
    am
    aw
    au
    at
    az
    bs
    bh
    bd
    bb
    by
    be
    bz
    bj
    bm
    bt
    bo
    ba
    bw
    bv
    br
    io
    bn
    bg
    bf
    bi
    kh
    cm
    ca
    cv
    ky
    cf
    td
    cl
    cn
    cx
    cc
    co
    km
    cg
    cd
    ck
    cr
    ci
    hr
    cu
    cy
    cz
    dk
    dj
    dm
    do
    ec
    eg
    sv
    gq
    er
    ee
    et
    fk
    fo
    fj
    fi
    fr
    gf
    pf
    tf
    ga
    gm
    ge
    de
    gh
    gi
    gr
    gl
    gd
    gp
    gu
    gt
    gn
    gw
    gy
    ht
    hm
    va
    hn
    hk
    hu
    is
    in
    id
    ir
    iq
    ie
    il
    it
    jm
    jp
    jo
    kz
    ke
    ki
    kp
    kr
    kw
    kg
    la
    lv
    lb
    ls
    lr
    ly
    li
    lt
    lu
    mo
    mk
    mg
    mw
    my
    mv
    ml
    mt
    mh
    mq
    mr
    mu
    yt
    mx
    fm
    md
    mc
    mn
    ms
    ma
    mz
    mm
    na
    nr
    np
    nl
    an
    nc
    nz
    ni
    ne
    ng
    nu
    nf
    mp
    no
    om
    pk
    pw
    ps
    pa
    pg
    py
    pe
    ph
    pn
    pl
    pt
    pr
    qa
    re
    ro
    ru
    rw
    sh
    kn
    lc
    pm
    vc
    ws
    sm
    st
    sa
    sn
    cs
    sc
    sl
    sg
    sk
    si
    sb
    so
    za
    gs
    es
    lk
    sd
    sr
    sj
    sz
    se
    ch
    sy
    tw
    tj
    tz
    th
    tl
    tg
    tk
    to
    tt
    tn
    tr
    tm
    tc
    tv
    ug
    ua
    ae
    gb
    us
    um
    uy
    uz
    vu
    ve
    vn
    vg
    vi
    wf
    eh
    ye
    zm
    zw
);

#  Frequently Occurring First Names and Surnames From the 1990 Census
#  Most frequent appearing first.
#  See http://www.census.gov/genealogy/names/

my @fname = qw
(
    james
    john
    robert
    michael
    william
    david
    richard
    charles
    joseph
    thomas
    christopher
    daniel
    paul
    mark
    donald
    george
    kenneth
    steven
    edward
    brian
    ronald
    anthony
    kevin
    jason
    matthew
    gary
    timothy
    jose
    larry
    jeffrey
    frank
    scott
    eric
    stephen
    andrew
    raymond
    gregory
    joshua
    jerry
    dennis
    walter
    patrick
    peter
    harold
    douglas
    henry
    carl
    arthur
    ryan
    roger
    joe
    juan
    jack
    albert
    jonathan
    justin
    terry
    gerald
    keith
    samuel
    willie
    ralph
    lawrence
    nicholas
    roy
    benjamin
    bruce
    brandon
    adam
    harry
    fred
    wayne
    billy
    steve
    louis
    jeremy
    aaron
    randy
    howard
    eugene
    carlos
    russell
    bobby
    victor
    martin
    ernest
    phillip
    todd
    jesse
    craig
    alan
    shawn
    clarence
    sean
    philip
    chris
    johnny
    earl
    jimmy
    antonio
    danny
    bryan
    tony
    luis
    mike
    stanley
    leonard
    nathan
    dale
    manuel
    rodney
    curtis
    norman
    allen
    marvin
    vincent
    glenn
    jeffery
    travis
    jeff
    chad
    jacob
    lee
    melvin
    alfred
    kyle
    francis
    bradley
    jesus
    herbert
    frederick
    ray
    joel
    edwin
    don
    eddie
    ricky
    troy
    randall
    barry
    alexander
    bernard
    mario
    leroy
    francisco
    marcus
    micheal
    theodore
    clifford
    miguel
    oscar
    jay
    jim
    tom
    calvin
    alex
    jon
    ronnie
    bill
    lloyd
    tommy
    leon
    derek
    warren
    darrell
    jerome
    floyd
    leo
    alvin
    tim
    wesley
    gordon
    dean
    greg
    jorge
    dustin
    pedro
    derrick
    dan
    lewis
    zachary
    corey
    herman
    maurice
    vernon
    roberto
    clyde
    glen
    hector
    shane
    ricardo
    sam
    rick
    lester
    brent
    ramon
    charlie
    tyler
    gilbert
    gene
    marc
    reginald
    ruben
    brett
    angel
    nathaniel
    rafael
    leslie
    edgar
    milton
    raul
    ben
    chester
    cecil
    duane
    franklin
    andre
    elmer
    brad
    gabriel
    ron
    mitchell
    roland
    arnold
    harvey
    jared
    adrian
    karl
    cory
    claude
    erik
    darryl
    jamie
    neil
    jessie
    christian
    javier
    fernando
    clinton
    ted
    mathew
    tyrone
    darren
    lonnie
    lance
    cody
    julio
    kelly
    kurt
    allan
    nelson
    guy
    clayton
    hugh
    max
    dwayne
    dwight
    armando
    felix
    jimmie
    everett
    jordan
    ian
    wallace
    ken
    bob
    jaime
    casey
    alfredo
    alberto
    dave
    ivan
    johnnie
    sidney
    byron
    julian
    isaac
    morris
    clifton
    willard
    daryl
    ross
    virgil
    andy
    marshall
    salvador
    perry
    kirk
    sergio
    marion
    tracy
    seth
    kent
    terrance
    rene
    eduardo
    terrence
    enrique
    freddie
    wade
    austin
    stuart
    fredrick
    arturo
    alejandro
    jackie
    joey
    nick
    luther
    wendell
    jeremiah
    evan
    julius
    dana
    donnie
    otis
    shannon
    trevor
    oliver
    luke
    homer
    gerard
    doug
    kenny
    hubert
    angelo
    shaun
    lyle
    matt
    lynn
    alfonso
    orlando
    rex
    carlton
    ernesto
    cameron
    neal
    pablo
    lorenzo
    omar
    wilbur
    blake
    grant
    horace
    roderick
    kerry
    abraham
    willis
    rickey
    jean
    ira
    andres
    cesar
    johnathan
    malcolm
    rudolph
    damon
    kelvin
    rudy
    preston
    alton
    archie
    marco
    pete
    randolph
    garry
    geoffrey
    jonathon
    felipe
    bennie
    gerardo
    ed
    dominic
    robin
    loren
    delbert
    colin
    guillermo
    earnest
    lucas
    benny
    noel
    spencer
    rodolfo
    myron
    edmund
    garrett
    salvatore
    cedric
    lowell
    gregg
    sherman
    wilson
    devin
    sylvester
    kim
    roosevelt
    israel
    jermaine
    forrest
    wilbert
    leland
    simon
    guadalupe
    clark
    irving
    carroll
    bryant
    owen
    rufus
    woodrow
    sammy
    kristopher
    mack
    levi
    marcos
    gustavo
    jake
    lionel
    marty
    taylor
    ellis
    dallas
    gilberto
    clint
    nicolas
    laurence
    ismael
    orville
    drew
    jody
    ervin
    dewey
    al
    wilfred
    josh

    mary
    patricia
    linda
    barbara
    elizabeth
    jennifer
    maria
    susan
    margaret
    dorothy
    lisa
    nancy
    karen
    betty
    helen
    sandra
    donna
    carol
    ruth
    sharon
    michelle
    laura
    sarah
    kimberly
    deborah
    jessica
    shirley
    cynthia
    angela
    melissa
    brenda
    amy
    anna
    rebecca
    virginia
    kathleen
    pamela
    martha
    debra
    amanda
    stephanie
    carolyn
    christine
    marie
    janet
    catherine
    frances
    ann
    joyce
    diane
    alice
    julie
    heather
    teresa
    doris
    gloria
    evelyn
    jean
    cheryl
    mildred
    katherine
    joan
    ashley
    judith
    rose
    janice
    kelly
    nicole
    judy
    christina
    kathy
    theresa
    beverly
    denise
    tammy
    irene
    jane
    lori
    rachel
    marilyn
    andrea
    kathryn
    louise
    sara
    anne
    jacqueline
    wanda
    bonnie
    julia
    ruby
    lois
    tina
    phyllis
    norma
    paula
    diana
    annie
    lillian
    emily
    robin
    peggy
    crystal
    gladys
    rita
    dawn
    connie
    florence
    tracy
    edna
    tiffany
    carmen
    rosa
    cindy
    grace
    wendy
    victoria
    edith
    kim
    sherry
    sylvia
    josephine
    thelma
    shannon
    sheila
    ethel
    ellen
    elaine
    marjorie
    carrie
    charlotte
    monica
    esther
    pauline
    emma
    juanita
    anita
    rhonda
    hazel
    amber
    eva
    debbie
    april
    leslie
    clara
    lucille
    jamie
    joanne
    eleanor
    valerie
    danielle
    megan
    alicia
    suzanne
    michele
    gail
    bertha
    darlene
    veronica
    jill
    erin
    geraldine
    lauren
    cathy
    joann
    lorraine
    lynn
    sally
    regina
    erica
    beatrice
    dolores
    bernice
    audrey
    yvonne
    annette
    june
    samantha
    marion
    dana
    stacy
    ana
    renee
    ida
    vivian
    roberta
    holly
    brittany
    melanie
    loretta
    yolanda
    jeanette
    laurie
    katie
    kristen
    vanessa
    alma
    sue
    elsie
    beth
    jeanne
    vicki
    carla
    tara
    rosemary
    eileen
    terri
    gertrude
    lucy
    tonya
    ella
    stacey
    wilma
    gina
    kristin
    jessie
    natalie
    agnes
    vera
    willie
    charlene
    bessie
    delores
    melinda
    pearl
    arlene
    maureen
    colleen
    allison
    tamara
    joy
    georgia
    constance
    lillie
    claudia
    jackie
    marcia
    tanya
    nellie
    minnie
    marlene
    heidi
    glenda
    lydia
    viola
    courtney
    marian
    stella
    caroline
    dora
    jo
    vickie
    mattie
    terry
    maxine
    irma
    mabel
    marsha
    myrtle
    lena
    christy
    deanna
    patsy
    hilda
    gwendolyn
    jennie
    nora
    margie
    nina
    cassandra
    leah
    penny
    kay
    priscilla
    naomi
    carole
    brandy
    olga
    billie
    dianne
    tracey
    leona
    jenny
    felicia
    sonia
    miriam
    velma
    becky
    bobbie
    violet
    kristina
    toni
    misty
    mae
    shelly
    daisy
    ramona
    sherri
    erika
    katrina
    claire
    lindsey
    lindsay
    geneva
    guadalupe
    belinda
    margarita
    sheryl
    cora
    faye
    ada
    natasha
    sabrina
    isabel
    marguerite
    hattie
    harriet
    molly
    cecilia
    kristi
    brandi
    blanche
    sandy
    rosie
    joanna
    iris
    eunice
    angie
    inez
    lynda
    madeline
    amelia
    alberta
    genevieve
    monique
    jodi
    janie
    maggie
    kayla
    sonya
    jan
    lee
    kristine
    candace
    fannie
    maryann
    opal
    alison
    yvette
    melody
    luz
    susie
    olivia
    flora
    shelley
    kristy
    mamie
    lula
    lola
    verna
    beulah
    antoinette
    candice
    juana
    jeannette
    pam
    kelli
    hannah
    whitney
    bridget
    karla
    celia
    latoya
    patty
    shelia
    gayle
    della
    vicky
    lynne
    sheri
    marianne
    kara
    jacquelyn
    erma
    blanca
    myra
    leticia
    pat
    krista
    roxanne
    angelica

);

#  o   Frequently Occurring Spanish surnames From the 1990 Census
#      See http://www.census.gov/genealogy/www/spanname.html
#  o   Alphabetical Index of Chinese Surnames
#      http://www.geocities.com/Tokyo/3919/atoz.html

my @sname = qw
(
    Abeyta
    Abrego
    Abreu
    Acevedo
    Acosta
    Acuna
    Adame
    Adorno
    Agosto
    Aguayo
    Aguilar
    Aguilera
    Aguirre
    Alanis
    Alaniz
    Alarcon
    Alba
    Alcala
    Alcantar
    Alcaraz
    Alejandro
    Aleman
    Alfaro
    Alicea
    Almanza
    Almaraz
    Almonte
    Alonso
    Alonzo
    Altamirano
    Alva
    Alvarado
    Alvarez
    Amador
    Amaya
    Anaya
    Anguiano
    Angulo
    Aparicio
    Apodaca
    Aponte
    Aragon
    Arana
    Aranda
    Arce
    Archuleta
    Arellano
    Arenas
    Arevalo
    Arguello
    Arias
    Armas
    Armendariz
    Armenta
    Armijo
    Arredondo
    Arreola
    Arriaga
    Arroyo
    Arteaga
    Atencio
    Avalos
    Avila
    Aviles
    Ayala
    Baca
    Badillo
    Baez
    Baeza
    Bahena
    Balderas
    Ballesteros
    Banda
    Banuelos
    Barajas
    Barela
    Barragan
    Barraza
    Barrera
    Barreto
    Barrientos
    Barrios
    Batista
    Becerra
    Beltran
    Benavides
    Benavidez
    Benitez
    Bermudez
    Bernal
    Berrios
    Betancourt
    Blanco
    Bonilla
    Borrego
    Botello
    Bravo
    Briones
    Briseno
    Brito
    Bueno
    Burgos
    Bustamante
    Bustos
    Caballero
    Caban
    Cabrera
    Cadena
    Caldera
    Calderon
    Calvillo
    Camacho
    Camarillo
    Campos
    Canales
    Candelaria
    Cano
    Cantu
    Caraballo
    Carbajal
    Cardenas
    Cardona
    Carmona
    Carranza
    Carrasco
    Carrasquillo
    Carreon
    Carrera
    Carrero
    Carrillo
    Carrion
    Carvajal
    Casanova
    Casares
    Casarez
    Casas
    Casillas
    Castaneda
    Castellanos
    Castillo
    Castro
    Cavazos
    Cazares
    Ceballos
    Cedillo
    Ceja
    Centeno
    Cepeda
    Cerda
    Cervantes
    Cervantez
    Chacon
    Chapa
    Chavarria
    Chavez
    Cintron
    Cisneros
    Collado
    Collazo
    Colon
    Colunga
    Concepcion
    Contreras
    Cordero
    Cordova
    Cornejo
    Corona
    Coronado
    Corral
    Corrales
    Correa
    Cortes
    Cortez
    Cotto
    Covarrubias
    Crespo
    Cruz
    Cuellar
    Curiel
    Davila
    Deanda
    Dejesus
    Delacruz
    Delafuente
    Delagarza
    Delao
    Delapaz
    Delarosa
    Delatorre
    Deleon
    Delgadillo
    Delgado
    Delrio
    Delvalle
    Diaz
    Dominguez
    Dominquez
    Duarte
    Duenas
    Duran
    Echevarria
    Elizondo
    Enriquez
    Escalante
    Escamilla
    Escobar
    Escobedo
    Esparza
    Espinal
    Espino
    Espinosa
    Espinoza
    Esquibel
    Esquivel
    Estevez
    Estrada
    Fajardo
    Farias
    Feliciano
    Fernandez
    Ferrer
    Fierro
    Figueroa
    Flores
    Florez
    Fonseca
    Franco
    Frias
    Fuentes
    Gaitan
    Galarza
    Galindo
    Gallardo
    Gallegos
    Galvan
    Galvez
    Gamboa
    Gamez
    Gaona
    Garay
    Garcia
    Garibay
    Garica
    Garrido
    Garza
    Gastelum
    Gaytan
    Gil
    Giron
    Godinez
    Godoy
    Gomez
    Gonzales
    Gonzalez
    Gracia
    Granado
    Granados
    Griego
    Grijalva
    Guajardo
    Guardado
    Guerra
    Guerrero
    Guevara
    Guillen
    Gurule
    Gutierrez
    Guzman
    Haro
    Henriquez
    Heredia
    Hernadez
    Hernandes
    Hernandez
    Herrera
    Hidalgo
    Hinojosa
    Holguin
    Huerta
    Hurtado
    Ibarra
    Iglesias
    Irizarry
    Jaime
    Jaimes
    Jaquez
    Jaramillo
    Jasso
    Jimenez
    Jiminez
    Juarez
    Jurado
    Laboy
    Lara
    Laureano
    Leal
    Lebron
    Ledesma
    Leiva
    Lemus
    Leon
    Lerma
    Leyva
    Limon
    Linares
    Lira
    Llamas
    Loera
    Lomeli
    Longoria
    Lopez
    Lovato
    Loya
    Lozada
    Lozano
    Lucero
    Lucio
    Luevano
    Lugo
    Lujan
    Luna
    Macias
    Madera
    Madrid
    Madrigal
    Maestas
    Magana
    Malave
    Maldonado
    Manzanares
    Mares
    Marin
    Marquez
    Marrero
    Marroquin
    Martinez
    Mascarenas
    Mata
    Mateo
    Matias
    Matos
    Maya
    Mayorga
    Medina
    Medrano
    Mejia
    Melendez
    Melgar
    Mena
    Menchaca
    Mendez
    Mendoza
    Menendez
    Meraz
    Mercado
    Merino
    Mesa
    Meza
    Miramontes
    Miranda
    Mireles
    Mojica
    Molina
    Mondragon
    Monroy
    Montalvo
    Montanez
    Montano
    Montemayor
    Montenegro
    Montero
    Montes
    Montez
    Montoya
    Mora
    Morales
    Moreno
    Mota
    Moya
    Munguia
    Muniz
    Munoz
    Murillo
    Muro
    Najera
    Naranjo
    Narvaez
    Nava
    Navarrete
    Navarro
    Nazario
    Negrete
    Negron
    Nevarez
    Nieto
    Nieves
    Nino
    Noriega
    Nunez
    Ocampo
    Ocasio
    Ochoa
    Ojeda
    Olivares
    Olivarez
    Olivas
    Olivera
    Olivo
    Olmos
    Olvera
    Ontiveros
    Oquendo
    Ordonez
    Orellana
    Ornelas
    Orosco
    Orozco
    Orta
    Ortega
    Ortiz
    Osorio
    Otero
    Ozuna
    Pabon
    Pacheco
    Padilla
    Padron
    Paez
    Pagan
    Palacios
    Palomino
    Palomo
    Pantoja
    Paredes
    Parra
    Partida
    Patino
    Paz
    Pedraza
    Pedroza
    Pelayo
    Pena
    Perales
    Peralta
    Perea
    Peres
    Perez
    Pichardo
    Pina
    Pineda
    Pizarro
    Polanco
    Ponce
    Porras
    Portillo
    Posada
    Prado
    Preciado
    Prieto
    Puente
    Puga
    Pulido
    Quesada
    Quezada
    Quinones
    Quinonez
    Quintana
    Quintanilla
    Quintero
    Quiroz
    Rael
    Ramirez
    Ramon
    Ramos
    Rangel
    Rascon
    Raya
    Razo
    Regalado
    Rendon
    Renteria
    Resendez
    Reyes
    Reyna
    Reynoso
    Rico
    Rincon
    Riojas
    Rios
    Rivas
    Rivera
    Rivero
    Robledo
    Robles
    Rocha
    Rodarte
    Rodrigez
    Rodriguez
    Rodriquez
    Rojas
    Rojo
    Roldan
    Rolon
    Romero
    Romo
    Roque
    Rosado
    Rosales
    Rosario
    Rosas
    Roybal
    Rubio
    Ruelas
    Ruiz
    Ruvalcaba
    Saavedra
    Saenz
    Saiz
    Salas
    Salazar
    Salcedo
    Salcido
    Saldana
    Saldivar
    Salgado
    Salinas
    Samaniego
    Sanabria
    Sanches
    Sanchez
    Sandoval
    Santacruz
    Santana
    Santiago
    Santillan
    Sarabia
    Sauceda
    Saucedo
    Sedillo
    Segovia
    Segura
    Sepulveda
    Serna
    Serrano
    Serrato
    Sevilla
    Sierra
    Sisneros
    Solano
    Solis
    Soliz
    Solorio
    Solorzano
    Soria
    Sosa
    Sotelo
    Soto
    Suarez
    Tafoya
    Tamayo
    Tamez
    Tapia
    Tejada
    Tejeda
    Tellez
    Tello
    Teran
    Terrazas
    Tijerina
    Tirado
    Toledo
    Toro
    Torres
    Torrez
    Tovar
    Trejo
    Trevino
    Trujillo
    Ulibarri
    Ulloa
    Urbina
    Urena
    Urias
    Uribe
    Urrutia
    Vaca
    Valadez
    Valdes
    Valdez
    Valdivia
    Valencia
    Valentin
    Valenzuela
    Valladares
    Valle
    Vallejo
    Valles
    Valverde
    Vanegas
    Varela
    Vargas
    Vasquez
    Vazquez
    Vega
    Vela
    Velasco
    Velasquez
    Velazquez
    Velez
    Veliz
    Venegas
    Vera
    Verdugo
    Verduzco
    Vergara
    Viera
    Vigil
    Villa
    Villagomez
    Villalobos
    Villalpando
    Villanueva
    Villareal
    Villarreal
    Villasenor
    Villegas
    Yanez
    Ybarra
    Zambrano
    Zamora
    Zamudio
    Zapata
    Zaragoza
    Zarate
    Zavala
    Zayas
    Zelaya
    Zepeda
    Zuniga

    Ang
    Au-Yong
    Bai
    Ban
    Bao
    Bei
    Bian
    Bing
    Cai
    Cao
    Cen
    Chai
    Chaim
    Chan
    Chang
    Chao
    Che
    Chen
    Cheng
    Cheung
    Chew
    Chi
    Chieu
    Chin
    Chong
    Chou
    Chu
    Cong
    Cuan
    Cui
    Dai
    Dan
    Deng
    Der
    Ding
    Dong
    Dou
    Duan
    Eng
    Fan
    Fei
    Feng
    Foong
    Fung
    Gai
    Gan
    Gao
    Geng
    Gong
    Gou
    Guan
    Guang
    Gui
    Guo
    Han
    Hang
    Hao
    Hong
    Hor
    Hou
    Hsiao
    Hua
    Huan
    Huang
    Hui
    Huie
    Huo
    Jia
    Jian
    Jiang
    Jiao
    Jin
    Jing
    Jiu
    Joe
    Juan
    Jue
    Kan
    Kang
    Kau
    Khu
    Kong
    Koo
    Kuai
    Kuang
    Kui
    Kwan
    Lai
    Lam
    Lang
    Lao
    Lau
    Law
    Lee
    Lei
    Lew
    Lian
    Liang
    Liao
    Lim
    Lin
    Ling
    Liu
    Loh
    Long
    Loong
    Lou
    Louis
    Lu:
    Luo
    Mah
    Mai
    Mak
    Man
    Mao
    Mar
    Mei
    Meng
    Miao
    Min
    Ming
    Moy
    Nao
    Nie
    Niu
    Ou Yan
    Ow-Yang
    Pan
    Pang
    Pei
    Peng
    Pian
    Ping
    Qian
    Qiao
    Qin
    Qing
    Qiu
    Quan
    Que
    Ran
    Rang
    Rao
    Rong
    Ruan
    Rui
    Seah
    See Ma
    Seow
    Seto
    Sha
    Shan
    Shang
    Shao
    Shaw
    She
    Shen
    Sheng
    Shi
    Shu
    Shuai
    Shui
    Shuo
    Si Ma
    Si Tu
    Siew
    Siu
    Song
    Su-Tu
    Sui
    Sun
    Sze Ma
    Tai
    Tan
    Tang
    Tao
    Teng
    Teoh
    Thean
    Thian
    Thien
    Tian
    Tong
    Tow
    Tsang
    Tse
    Tso
    Tze
    Wan
    Wang
    Wei
    Wen
    Weng
    Won
    Wong
    Woo
    Xian
    Xiang
    Xiao
    Xie
    Xin
    Xing
    Xiong
    Xuan
    Xue
    Xun
    Yan
    Yang
    Yao
    Yap
    Yee
    Yep
    Yin
    Ying
    Yong
    You
    Yuan
    Yue
    Yun
    Zang
    Zeng
    Zha
    Zhai
    Zhan
    Zhang
    Zhao
    Zhen
    Zheng
    Zhi
    Zhong
    Zhou
    Zhu
    Zhuan
    Zhui
    Zhuo
    Zong
    Zou

);

# ****************************************************************************
#
#   DESCRIPTION
#
#	Print help and exit.
#
#   INPUT PARAMETERS
#
#	None.
#
#   RETURN VALUES
#
#	None.
#
# ****************************************************************************

=pod

=head1 NAME

wwwflypaper -  Generate a real-looking bogus web page

=head1 SYNOPSIS

  wwwflypaper(.pl) [OPTIONS] [URLROOT]

=head1 OPTIONS

=over 4

=item B<--help|--help-html|--help-man>

Print help. The default format is text. Option B<--help-html> displays
help in HTML format and --help-man in Unix manual page format.

=item B<--version>

Print version information.

=back

=head1 ARGUMENTS

=over 4

=item B<URLROOT>

In the generated web pages there are links that point back to the
page. These links (A HREF's in HTML) are by default prefixed with
C</email>. If the trap in the web server is put somewhere else, the
change must be told to the program in order to generate correct links.
See exmaples for more information.

=back

=head1 DESCRIPTION

Generate random list of real-looking bogus email addresses in the
form of a HTML mailing list page.

The page is dynamically made and full of convincingly lifelike - but
completely bogus - email addresses that spambots can pick up and add
to their hitlists. The page also contains randomly generated links
that the bot inevitably follows - links that loop right back to the
same page, now re-armed with a fresh set of random fake email
addresses.

This program can be used to combat the junk email problem by
effectively poisoning the databases of those gathering programs that
regularly scan web pages looking for email addresses to harvest. The
program is designed to be as fast as possible and self containing. No
separate dictionary files are needed.

The restrictive licensing terms of wpoison(1) inspired to
write a free alternative -- this program.

=head1 EXAMPLES

Let's suppose that local web server's robots file is located at
I<$WWWROOT/robots.txt> announces a forbidden fruit. The well behaving
search robots will ignore all URLs that are banned by the robots file.
But the email harvesting programs will surely want to take a look into
the URLs mentioned in one or more B<Disallow> lines in the
I<robots.txt> file:

    User-agent: *
    Disallow: /email

The idea is that system administrator will set up a trap, where every
access to pages under disallowed URLs lead to calls to this program.
Here is an example setup for Apache web server.

    <Location /email>
	<IfModule mod_rewrite.c>
	    RewriteEngine  On
	    RewriteRule    ^  /cgi-bin/wwwflypaper.pl
	</IfModule>

	AddType cgi-script html
	options +ExecCGI -Indexes
    </Location>

Place the program under I<$WWWCGIBIN> directory (e.g. C<
/usr/lib/cgi-bin/> if that's the Web server's CGI root) and the fly
paper trap is ready. Notice that the caret(^) matches every page
referred under C</email> location and redirects it to the program.
Verify the effect by accessing the page with browser:

   http://your.example.com/email

The default A HEREF links are set to I</email>, but this needs to
be changed from command line if another URL location in the web
server is used. Like if the trap were in:

    wwwflypaper.pl /mailing-list

=head1 TROUBLESHOOTING

None.

=head1 ENVIRONMENT

None used.

=head1 FILES

None used.

=head1 SEE ALSO

wpoison(1)

The wpoison <http://www.monkeys.com/wpoison>
does not comply with Debian Free Software Guidelines. See
<http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=122929> and
discussion at
<http://lists.debian.org/debian-legal/2001/12/msg00388.html>
<http://lists.debian.org/debian-legal/2001/12/msg00396.html>
<http://lists.debian.org/debian-legal/2001/12/msg00410.html>

=head1 STANDARDS

The output is HTML 4.01 Transitional valid. See
<http://www.w3.org/TR/html401/sgml/loosedtd.html>. Web servers and
robots.txt standard is at <http://www.robotstxt.org>.

=head1 BUGS

The programs is designed as fast as possible and to be completely self
standing. There are no plans to support external lookup dictionaries
or other external configurations.

=head1 AVAILABILITY

<URL Where to get the program>

=head1 SCRIPT CATEGORIES

CPAN/Administrative

=head1 PREREQUISITES

No Perl CPAN modules are used.

=head1 COREQUISITES

Only modules from standard Perl are used.

=head1 OSNAMES

C<any>

=head1 AUTHOR

Copyright (C) 2005-2007 Jari Aalto.
This program is free software; you can redistribute and/or modify program
under the same terms as Perl itself or in terms of Gnu General Public
licence v2 or later.

=cut

sub Help (;$ $)
{
    my $type = shift;  # optional arg, type

    if ( $type eq -html )
    {
        pod2html $0;
    }
    elsif ( $type eq -man )
    {
        eval "use Pod::Man";
        $@  and  die "$0: Cannot generate Man: $@";

        my %options;
        $options{center} = "Generate fake web page ($VERSION)";

        my $parser = Pod::Man->new(%options);
        $parser->parse_from_file($0);
    }
    else
    {
        pod2text $0;
	print "Version: $FILE_ID\n";
    }

    exit 0;
}

# ****************************************************************************
#
#   DESCRIPTION
#
#	Pick random item from array. The item's length must be over 4
#	characters.
#
#   INPUT PARAMETERS
#
#	\@		Array reference to the list of words.
#
#   RETURN VALUES
#
#	$		String.
#
# ****************************************************************************

sub GetWord ($)
{
    #   get a random word of at least 4 characters

    my $id   = "GetWord";
    my $aref = shift;
    my $word = "";

    ! @$aref  and  die "$id: ARRAY is empty";

    while ( length $word < 4 )
    {
	$word = $$aref[ int rand @$aref ];
    }

    $word;
}

# ****************************************************************************
#
#   DESCRIPTION
#
#	Pick random letter.
#
#   INPUT PARAMETERS
#
#	None.
#
#   RETURN VALUES
#
#	$	One character string. A Random letter.
#
# ****************************************************************************

sub GetLetter ()
{
    #   get a random letter
    my $list = "abcdefghijklmnopqrstuvwxyz0123456789";
    substr $list, int rand length $list, 1;
}

# ****************************************************************************
#
#   DESCRIPTION
#
#	Start of the programs
#
#   INPUT PARAMETERS
#
#	Command line options. See Help() or run program with --help.
#
#   RETURN VALUES
#
#	HTML web page. The first line contains Content-Type header required by
#	the Web servers
#
# ****************************************************************************

sub Listname ()
{
    my $word1    = ucfirst $titles[ int rand @titles ];
    my $listname = sprintf "%s %s Mailing List"
	         , ucfirst $word1
		 #  Make sure we do not pick the same word again.
	         , ucfirst( (grep !/$word1/, @titles)[ int rand @titles - 1])
		 ;

    return $listname;
}

# ****************************************************************************
#
#   DESCRIPTION
#
#	Generate new URL links that point back to the "trap" (this program)
#
#   INPUT PARAMETERS
#
#	@		Array of words that are used for the visible URL
#                       link names.
#	$ROOTDIR	[global] The web server's location prefix for all URLs.
#
#   RETURN VALUES
#
#	None. The web page HTML code is outputted to stdout.
#
# ****************************************************************************

sub AddLinks ($)
{
    print "\n<DL><DT>Links to other mailing list pages:\n";

    my ($words) = @_;

    for my $i ( 0 .. 15 )
    {
	my $page  = GetWord $words;
	my $text  = Listname();
	my $link  = "$ROOTDIR/$page.html";

	$link =~ s/[\s\n\r]+//g;
	print "<DD><A HREF=\"$link\">$text</A>\n";
    }

    print "</DL><HR>\n";
}

# ****************************************************************************
#
#   DESCRIPTION
#
#	Start of the programs
#
#   INPUT PARAMETERS
#
#	Command line options. See Help() or run program with --help.
#
#   RETURN VALUES
#
#	HTML web page. The first line contains Content-Type header required by
#	the Web servers
#
# ****************************************************************************

sub Main ()
{
    #  Don't use Perl module Getop::Long to make this program as
    #  fast as possible for busy Web servers. Read args "old fashioned".

    grep /^(--help|-h)$/i,   @ARGV  and Help();
    grep /^(--help-html)$/i, @ARGV  and Help -html;
    grep /^(--help-man)$/i,  @ARGV  and Help -man;
    grep /^(--version|-v)/i, @ARGV  and print("$VERSION\n"), exit;

    my($dir) = @ARGV;

    $ROOTDIR  = $dir       if $dir;

    $| = 1;   # $OUTPUT_AUTOFLUSH

    # seed random number generator

    srand time;

    # how many addresses to give at a time: make it different every time

    my $numadds  = 100 + int rand 100;

    # start the HTML output.

    print "Content-type: text/html; $CHARSET\n\n" . $DOCTYPE;

    my $listname = Listname();

    print qq
    (
	<HTML>
	<HEAD>
	   <TITLE>The Mailing List in this server</TITLE>
	</HEAD>

	<BODY>

	<H1 ALIGN="CENTER">$listname information</H1>
	<P>This is for the use of $listname only.
	</P>
    );

    my @alphaset = ( 'a' .. 'z' );
    my $count = 100;
    my @words;

    for my $i (0 .. $count)
    {
	my $word = '';

	for my $j ( 0 .. rand(4) + 3 )
	{
	    $word = $word . $alphaset[rand 25];
	}

	push @words, $word;
    }

    chomp @words;

    AddLinks \@words;

    my @list;
    my @tlds = (@tld, @countries);

    for my $i ( 0 .. $numadds )
    {
	my $user    = ucfirst lc GetWord \@words;
	my $fname   = ucfirst $fname[ int rand @fname ];
	my $sname   = ucfirst $sname[ int rand @sname ];
	my $name    = "$fname $sname";

	my $dname   = $dname[ int rand @dname ];
	my $tld     = $tlds[ int rand @tlds ];

	my $domain  = sprintf "%s.%s.%s"
		      , $dname
		      , GetWord(\@words) . GetLetter()
		      , $tld
		      ;

	my $email   = lc sprintf "%s.%s@%s", $fname, $sname, $domain;

	push @list, qq(<LI>$name <A HREF="mailto:$email">$email</A>\n);
    }

    print "\n\n<UL>\n", @list, "</UL> \n\n</BODY> \n</HTML>\n";
}

Main();

# End of file
