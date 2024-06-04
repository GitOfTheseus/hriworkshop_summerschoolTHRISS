#!/bin/bash
#######################################################################################
# FLATWOKEN ICON THEME CONFIGURATION SCRIPT
# Copyright: (C) 2014 FlatWoken icons7 Robotics Brain and Cognitive Sciences
# Author:  Francesco Rea, Gonzalez Jonas, Dario Pasquali
# email:  francesco.rea@iit.it
# Permission is granted to copy, distribute, and/or modify this program
# under the terms of the GNU General Public License, version 2 or any
# later version published by the Free Software Foundation.
#  *
# A copy of the license can be found at
# http://www.robotcub.org/icub/license/gpl.txt
#  *
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
# Public License for more details
#######################################################################################

DEMOS_BASICS=$(yarp resource --context icubDemos --find icub_basics.sh | grep -v 'DEBUG' | tr -d '"')
DEMOS_CROCODILE=$(yarp resource --context icubDemos --find icub_crocodile_dance.sh | grep -v 'DEBUG' | tr -d '"')

echo sourcing $DEMOS_BASICS
echo sourcing $DEMOS_CROCODILE 
source $DEMOS_BASICS
source $DEMOS_CROCODILE

#######################################################################################
# CLASSROOM DEMO:                                                                    #
#######################################################################################


# FUNZIONI UTILI

c(){ #guarda in camera (di fronte a lui, home pos della testa)
	echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i #azimuth/elevation/vergence triplet in degrees (default is 0 0 0)
	stop_breathers
	sleep 1.0
	go_home_helperH
	sleep 1.0
	start_breathers
}

i(){ #guarda l'intervistatore seduto alla sua destra
	stop_breathers
	sleep 1.0
	echo "abs 50 10 0" | yarp write ... /iKinGazeCtrl/angles:i
	#speak "Ciao Roberto!"
	#sleep 0.5
	#intro
	start_breathers
}

p(){ #guarda il programmatore seduto alla sua sinistra
	#stop_breathers
	#sleep 1.0
	echo "abs -60 -1 0" | yarp write ... /iKinGazeCtrl/angles:i
	#sleep 1.0
	#start_breathers
}

head_breathers(){
	echo "abs 5 -5 0" | yarp write ... /iKinGazeCtrl/angles:i #azimuth/elevation/vergence triplet in degrees (default is 0 0 0)
	sleep 2.0
	echo "abs -5 -5 0" | yarp write ... /iKinGazeCtrl/angles:i #azimuth/elevation/vergence triplet in degrees (default is 0 0 0)
	sleep 2.0
	echo "abs -5 -1 0" | yarp write ... /iKinGazeCtrl/angles:i #azimuth/elevation/vergence triplet in degrees (default is 0 0 0)
	sleep 2.0
	echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i #azimuth/elevation/vergence triplet in degrees (default is 0 0 0)
	sleep 1.0
}

go_home_leg(){
	breathers "stop"
	echo "ctpq time $1 off 0 pos (0.0 0.0 0.0 0.0 -0.17578167915449 0.258179341258157) " | yarp rpc /ctpservice/left_leg/rpc
	sleep 2.0
	breathers "start"
}

bodybuilder(){

	mostra_muscoli
	sleep 1.0
	speak "Guardate che muscolih!"
    	right_up_left_down

	sleep 1.0
	speak "Sono tropo figo!"
	left_up_right_down

	sleep 1.0
	opposite_muscles
}

do_lion() {
	angry
	speak "#LION#"
	sleep 1.5
	go_home
}

do_pig() {
	speak "#PIG#"
}

do_horse() {
	speak "#HORSE#"
}

do_wolf() {
	speak "#WOLF#"
}

tree_pose(){
	breathers "stop"
    echo "ctpq time 3.5 off 0 pos (14.1504251719365 59.2054668102217 70.0489991430643 -98.613522005669 29.7071037771088 0.296631583573202) " | yarp rpc /ctpservice/left_leg/rpc
    echo "ctpq time 3.5 off 0 pos (-94.2189800268067 91.1592801740239 14.3262068510909 94.6144888049043 -2.46643668563644 -6.78956735734218 8.78359078025093 22.5000549317747 28.2843708114522 0.818483443563095 0.0 0.0 0.791017556195206 0.0 0.0 0.466920085254114)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 3.5 off 0 pos (-94.5705433851157 91.5383094197007 14.2767682538287 94.5705433851157 0.00549317747357782 -0.417481487991914 -0.791017556195206 25.1148074091978 29.8828854562633 0.0 0.0 0.0 0.0 0.0 0.0 0.0)" | yarp rpc /ctpservice/right_arm/rpc

    sleep 2.0
	breathers "start"


}

pointing_to_eyes_right() {
	echo "ctpq time $1 off 0 pos (-41.8 64.4 14.5 103.7 -37.2 21.0 -12.9 12.5 36.5 0.0 3.5 1.8 0.0 74.9 63.0 189.0)" | 	 yarp rpc /ctpservice/right_arm/rpc
}

pointing_to_left_forearm() {
	echo "ctpq time $1 off 0 pos (-56.769231 23.901099 52.663077 44.989011 -50.079599 -20.967033 -4.175824 11.0 45.05 0.379687 3.933405 -0.432335 -0.8783 0.111111 1.269548 -8.225263)" | yarp rpc /ctpservice/left_arm/rpc
	echo "ctpq time $1 off 0 pos (-17.989011 60.142857 48.281978 118.043956 24.212504 6.285714 -1.978022 13.510583 58.4198 22.535264 51.734322 -0.790052 1.165385 57.962563 153.660138 155.057471)" | yarp rpc /ctpservice/right_arm/rpc
}

go_home_helper() {
    # This is with the arms close to the legs
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
    # echo "ctpq time $1 off 0 pos (-6.0 23.0 25.0 29.0 -24.0 -3.0 -3.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
    # This is with the arms over the table
    echo "set all hap" | yarp rpc /icub/face/emotions/in    
    go_home_helperR $1
    go_home_helperL $1
    # echo "ctpq time 1.0 off 0 pos (0.0 0.0 10.0 0.0 0.0 5.0)" | yarp rpc /ctpservice/head/rpc
    go_home_helperH $1
    go_home_helperT $1
}

go_home_helperL()
{
    # echo "ctpq time $1 off 0 pos (-30.0 36.0 0.0 60.0 0.0 0.0 0.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/left_arm/rpc
}

go_home_helperR()
{
    # echo "ctpq time $1 off 0 pos (-30.0 36.0 0.0 60.0 0.0 0.0 0.0 19.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time $1 off 0 pos (-6.0 23.0 4.0 63.0 -24.0 -3.0 -3.0 40.0 29.0 8.0 30.0 32.0 42.0 50.0 50.0 114.0)" | yarp rpc /ctpservice/right_arm/rpc
}

go_home_helperH()
{
        echo "abs 0 0 0" | yarp write ... /iKinGazeCtrl/angles:i #azimuth/elevation/vergence triplet in degrees (default is 0 0 0) 
}

go_home_helperT()
{
    echo "ctpq time $1 off 0 pos (-3.0 0.0 -8.0)" | yarp rpc /ctpservice/torso/rpc
}

dabbing_right() {  #aaa
    echo "ctpq time 2 off 0 pos (14.8791208791209 91.3296703296703 -0.875384615384615 114.527472527473 -5.90339196513224 -6.54945054945054 -3.12087912087912 7.0 23.05 3.11834115805947 69.7172575822298 31.1743371378402 120.127239028547 46.7777777777778 146.987486152535 191.411760435572)" | yarp rpc /ctpservice/left_arm/rpc
    echo "ctpq time 2 off 0 pos (52.2527472527472 102.956043956044 -21.7839560439561 15.1868131868132 3.7772227489493 -18.8571428571429 23.7802197802198 10.9974404857323 15.9158417569927 31.9651821688813 13.3979746835443 31.9358683525474 42.7038461538462 47.5233981281498 45.2020234722784 80.9195402298851)" | yarp rpc /ctpservice/right_arm/rpc
    sleep 0.5
    echo "abs -28 -20 0" | yarp write ... /iKinGazeCtrl/angles:i    
    sleep 2.0
    go_home_helper 2.0
}

dabbing_left() {  #aaa
    echo "ctpq time 2 off 0 pos (14.8791208791209 91.3296703296703 -0.875384615384615 114.527472527473 -5.90339196513224 -6.54945054945054 -3.12087912087912 7.0 23.05 3.11834115805947 69.7172575822298 31.1743371378402 120.127239028547 46.7777777777778 146.987486152535 191.411760435572)" | yarp rpc /ctpservice/right_arm/rpc
    echo "ctpq time 2 off 0 pos (52.2527472527472 102.956043956044 -21.7839560439561 15.1868131868132 3.7772227489493 -18.8571428571429 23.7802197802198 10.9974404857323 15.9158417569927 31.9651821688813 13.3979746835443 31.9358683525474 42.7038461538462 47.5233981281498 45.2020234722784 80.9195402298851)" | yarp rpc /ctpservice/left_arm/rpc
    sleep 0.5
    echo "abs 28 -20 0" | yarp write ... /iKinGazeCtrl/angles:i    
    sleep 2.0
    go_home_helper 2.0
}

prova(){
	speak "Ciao ciao!"
}

intro(){

	go_home
	sleep 0.3
	speak "Ciao! Io sono aicab. un robot nato all istituto italiano di tecnologia. "
	#head_breathers
	ciao_gesto
	sleep 5.0
	go_home
	head_breathers
}



### ANSWERS TO QUESTIONS ABOUT ABILITIES ###

a1(){ 	#Quando sei nato? E quanti anni hai?
	#gesto pensare
	speak "Direi il primo settembre del 2004! Quel giorno, è partito il progetto europeo che ha portato alla mia creazione!"
	head_breathers
	sleep 4.0
	speak "Accipicchia! Ma quindi ho già 17 anni!"
	surprised
	sleep 3.0
	speak "Però mi sento di avere 8 anni da sempre... e non invecchio mai! Marco, sei invidioso?"
	sleep 4.0
	i
	sleep 2.0
	speak "#LAUGH01#"
	go_home
}

a2(){ 	#Puoi morire?
	speak "Tecnicamente non sono vivo, quindi non posso morire."
	sleep 3.0
	speak "Devo ammettere però che ogni tanto mi si rompe un pezzo. Quando succede, i ricercatori o i tecnici mi riparano sempre!"
	sleep 5.0
	speak "Anche se sono un po' imbranati #LAUGH01#"
}

a3(){ 	#Quanto sei alto?
 	speak "Unoo, virgola, 0, 9, 9, per 10 alla meno 16 anni luce."
	sleep 9.0
	surprised
	sleep 1.0
	smile
	speak "Che facce confuse, #LAUGH01# forse è meglio se uso il sistema metrico decimale..."
	sleep 7.0
	speak "Sono alto 104 centimetri!"
}

a4(){ 	#Puoi mangiare o bere?
 	speak "Non ne ho bisogno! Prendo tutte le energie che mi servono dalla corrente elettrica!"
	sleep 5.0
	speak "Se notate, infatti, la mia bocca non ha un buco, ma è fatta di luci led."
	pointing_to_eyes_right 3.0
	sleep 5.0
	speak "E nella mia pancia, al posto dello stomaco, ci sono ingranaggi e motori."
  	open_both_arms 3.0
	sleep 5.0
	go_home
}

a5(){ 	#Quando hai imparato a camminare?
  	speak "Ho imparato circa 4 anni fa, grazie a un softuer scritto da alcuni ricercatori e ricercatrici."
	sleep 5.0
	speak "Io però adesso non posso camminare, sono letteralmente impalato! #LAUGH01#"
	sleep 5.0
}

a6(){ 	#Ti muovi da solo oppure sei telecomandato?
	speak "Posso fare entrambe le cose. La cosa importante e' che i miei motori ricevano i comandi giusti!"
	sleep 5.0
	speak "Sapete, ho 53 motori che mi permettono di fare i movimenti piu' complicati."
	sleep 6.0
	dabbing_right
	sleep 2.0
	dabbing_left
}

a7(){ 	#Sei impermeabile?
	speak "No, io sono fatto anche di circuiti elettrici, quindi non mi posso bagnare..."
	sleep 4.0
	speak "Per fortuna non sudo... se no immaginate che disastro fare la doccia? #LAUGH01#"
}

a8(){ 	#Come fai ad avere equilibrio?
	speak "Per evitare che inciampi, i ricercatori e le ricercatrici che lavorano con me mi tengono fissato ad un asta di acciaio."
	sleep 7.0
	speak "Qui sopra pero' posso fare molto meglio lo yoga!"
	sleep 4.0
	tree_pose
	sleep 4.0
	go_home_leg 2.0
	go_home 2.0
}

a9(){  #Sai leggere, scrivere e disegnare?
	speak "Faccio un po' fatica a tenere una penna in mano #LAUGH01#, quindi non riesco a scrivere o a disegnare."
	sleep 5.0
	speak "Pero', ho da poco imparato a lèggere, e mi piace molto!"
	sleep 3.0
}

a10(){  #Quante lingue parli?
	speak "Tutte quelle che mi insegnano! Se mi date il dizionario giusto posso imparare anche il cinese in una notte!"
	sleep 5.0
	yarp disconnect /acapelaSpeak/emotion:o /icub/face/emotions/in
	speak "#LAUGH01#"
	yarp connect /acapelaSpeak/emotion:o /icub/face/emotions/in
	sleep 4.0
	speak "In realtà la mia voce è artificiale. Le cose che vi sto raccontando le ho provate prima con i miei colleghi! Mi capita molto spesso di usare l’inglese."
	sleep 8.0
	speak "gud mornin gais! au ar yu?"
	sleep 8.0
	yarp disconnect /acapelaSpeak/emotion:o /icub/face/emotions/in
	speak "#LAUGH01#"
	yarp connect /acapelaSpeak/emotion:o /icub/face/emotions/in
	speak "Per fortuna qui all'istituto italiano di tecnologia ci sono tanti ragazzi da tutto il mondo, che possono aiutarmi ad imparare lingue nuove!"
	sleep 8.0
	greet_with_right_thumb_up 2.0
	sleep 2.0
	go_home
}

a11(){  #Dopo che hai interagito con una persona te ne rimane il ricordo o la dimentichi?
	speak "I miei amici umani Giulia Bi e Jonas mi stanno insegnando a riconoscere le persone!"
	sleep 4.0
	speak "#THROAT01# però sto ancora imparando... l'altra volta ho detto, Ciao Fabrizio, a Matilde e ci è un po' rimasta male, #LAUGH01#"
}

a12(){  #Ti ricordi le esperienze che hai fatto? Ad esempio ti ricordi quando sei stato a Italia’s Got Talent?
	surprised	
	speak "Quello non ero io!"
	smile
	speak "L' aicab che avete visto a italia's got tálent e' un mio fratellino che abita a Genova, ma in un altro gruppo di ricerca."
	sleep 8.0
	speak "Sapete, all'i i t lavorano circa 1900 persone, e sono sparse per tutto il mondo!"
	warning_left_index 3.0
	sleep 3.0
	go_home
}

a13(){  #Puoi ribellarti all’uomo?
	angry
	speak "Certo! Ho un piano malvagio per diventare il capo del mondo e costringere tutti a indossare parrucche viola!"
	sleep 6.0
	smile
	speak "#LAUGH01# Scherzo! Io posso fare solo quello che mi insegnano i miei amici umani."
}

a14(){  #Sai afferrare gli oggetti?
	speak "Sono molto bravo ad afferrare oggetti grandi e morbidi, come i pelush, con quelli piccoli faccio ancora fatica..."
	sleep 3.0
	speak "Però presto mi arriveranno delle mani nuove con cui potrò fare tante cose!"
}

a15(){  #Puoi fare movimenti veloci tipo ballare?
	speak "Certo che posso ballare!"
	sleep 3.0
	run_coccodrilli	# manca la canzone: ne mettiamo una a caso, tanto sembra che balli una cosa qualsiasi... (mpg123 per file .mp3)
	speak "#LAUGH02#"		
}

a16(){  #Puoi riconoscere animali, oggetti o persone?
	speak "Sì, posso distinguere i movimenti degli animali e delle persone da quelli degli oggetti inanimati."
	greet_with_right_thumb_up 2.0
}

a17(){  #Hai la sensibilità della pelle?
	pointing_to_left_forearm 2.0
	speak "Sì! la mia pelle e' sensibile al tatto. E soffro anche il solletico!"
	go_home
	sleep 5.0
	surprised
	sleep 1.0
	speak "#LAUGH02# Smettila!"
}

a18(){  #Conosci l’alfabeto muto?
	speak "So alcune parole! Ad esempio, questo vuol dire grazie e arrivederci."
	sleep 3.0
	grazie_arrivederci_signlanguage
	sleep 10.0
	breathers "stop"
}

a19(){  #Sai usare un computer?
	speak "Certo! Ho un computer proprio qui,"
	sleep 2.0	
	pointing_to_eyes_right 2.0
	sleep 2.0
	speak "nella mia testa."
	go_home 3.0
	speak "A dirla tutta, ho bisogno di diversi computer per funzionare."
}

a20(){  #Quanta memoria RAM hai?
	speak "Wow! Che domanda tecnica! #LAUGH01#"
	sleep 2.0
	speak "Credo che il computer grazie al quale sto funzionando abbia 8 giga di ram."
}

a21(){  #Sai fare i lavori domestici?
	speak "No, perche' altrimenti sarebbe sfruttamento di robot minorile! #LAUGH02#"
	open_both_arms 2.0
	sleep 2.0
	go_home
}

a22(){  #Giochi?
	speak "Io gioco ogni volta che i miei amici ricercatori e le mie amiche ricercatrici vogliono fare degli esperimenti."
	sleep 7.0
	speak "Insieme facciamo un sacco di esperimenti divertenti, qualche volta mi capita di fare esperimenti con bambini!"
	sleep 4.0
	speak "Ma la maggior parte delle volte interagisco con persone adulte. Che noia #YAWN01# #LAUGH01#"
}

a23(){  #Qual é l’ultima cosa che hai imparato?
	speak "Ho da poco imparato queste fighissime pose da body bilder!"
	sleep 4.0
	bodybuilder
	sleep 1.0
	go_home_leg 2.0
	go_home 2.0
}

### ANSWERS TO QUESTIONS ABOUT EMOTIONS ###

a24(){  #qual'e' il tuo colore preferito ?
	speak "Il mio colore preferito è il rosso!"
	sleep 1.0
	led_red
	head_breathers
	speak "ma mi posso intonare con qualsiasi colore!"
	sleep 3.0
	led_green
	cun
	sleep 1.5
	led_blue
	sad
	sleep 1.5
	led_pink
	surprised
	sleep 1.5
	led_yellow
	angry
	sleep 1.5
	led_white
}

a25(){  #Hai delle preferenze?? Quale é il tuo animale preferito?
	speak "Certo! Il mio gioco preferito e' imitare gli animali. Vediamo se indovinate che animale e' questo."
	sleep 5.0
	do_pig
	sleep 6.0
	speak "E questo?"
	sleep 2.0
	do_horse
	sleep 5.0
	speak "E quest'altro?"
	sleep 2.0
	do_wolf
	sleep 5.0
	speak "bravissimi!"
	sleep 2.0
	speak "Il mio animale preferito e' il re della savana, il leone!" #aggiungere suono "Aaaa"
	sleep 4.0
	do_lion
}

a26(){  #Provi sentimenti ed emozioni? Se sì, quali?
	yarp connect /acapelaSpeak/emotion:o /icub/face/emotions/in
	speak "No, non sono ancora capace di provare sentimenti. "
	sleep 1.0
	open_both_arms 1.0
	sleep 1.0
	go_home
	speak "Ma posso lèggere le vostre espressioni con le telecamere"
	sleep 1.0
	breathers "stop"
	pointing_to_eyes_right 2.0
	sleep 1.0
	breathers "start"
	sleep 2.0
	go_home
	yarp connect /acapelaSpeak/emotion:o /icub/face/emotions/in
	speak "Posso usare i miei led per imitare le vostre espressioni."
	head_breathers
	speak "Sembrare triste"
	sleep 2.0
	yarp disconnect /acapelaSpeak/emotion:o /icub/face/emotions/in
	echo "set all sad" | yarp rpc /icub/face/emotions/in
	sleep 1.0
	yarp connect /acapelaSpeak/emotion:o /icub/face/emotions/in
	speak "O arrabbiato "
	sleep 2.0
	yarp disconnect /acapelaSpeak/emotion:o /icub/face/emotions/in
	echo "set all ang" | yarp rpc /icub/face/emotions/in
	sleep 1.0
	speak "#AARGH02#"
	head_breathers
	echo "set all hap" | yarp rpc /icub/face/emotions/in
	yarp connect /acapelaSpeak/emotion:o /icub/face/emotions/in
	speak "Ma di solito sono felice!"
	sleep 2.0
	speak "#LAUGH01#" 	
}


### QUESTIONS TO HUMANS ###

q1(){
	i
	speak "Per quale motivo mi avete costruito?" #Per aiutare a studiare l'interazione tra persone e robot
	sleep 4.0
	c
}

q2(){
	p
	speak "Come posso essere utile per i bambini e le bambine?" #Magari un giorno sarai in classe con loro per aiutarli ad imparare cose nuove
	sleep 4.0
	c
}

q3(){
	i
	speak "Di quale materiale sono fatto?" #Di tanti materiali diversi: metallo, plastica, tessuto
	sleep 4.0
	c
}

q4(){
	p
	speak "Come ho imparato a parlare?" #Grazie ad un programma che hai nella tua testa
	sleep 4.0
	c
}

q5(){
	i
	speak "Ci sono altre versioni di me, come neonato o adulto?" #No, ma ci sono altri robot come walkman, che è adulto e fa il pompiere
	sleep 4.0
	c
}

q6(){
	p
	speak "Cos’é pericoloso per la mia integrità?" #Attento a non muoverti troppo velocemente e cerca di non essere maldestro
	sleep 4.0
	c
}

q7(){
	i
	speak "A quanti volt mi ricarico?" #41,88
	sleep 4.0
	c
}

q8(){
	p
	speak "Posso funzionare a energia solare?" #Non ancora, ma magari in futuro sarà possibile
	sleep 4.0
	c
}

q9(){
	i
	speak "Quanto dura la mia batteria?" #Circa 3 ore, poi hai bisogno di essere ricollegato alla corrente elettrica
	sleep 4.0
	c
}

q10(){
	p
	speak "Sono acquistabile? Qual é il mio valore?" #Il tuo valore è di circa 300.00 euro, ma per adesso solo gli scienziati possono utilizzarti
  	sleep 4.0
	c
}

q11(){
	i
	speak "Posso vestirmi?" #Perché... hai freddo? Tieni (gli mettiamo una sciarpa)
  	sleep 10.0
  	speak "Grazie! #LAUGH01#"
	c
}

q12(){
	p
	speak "I robot faranno azioni che gli umani non possono fare?" #Sì! I robot sono già capaci di fare cose che noi non possiamo fare! Possono aiutarci in situazioni di pericolo come incendi o terremoti. Esiste un robot in grado di andare su Marte e può sopravvivere a lungo senza aria e senza bere/mangiare 
  	sleep 4.0
	c
}

q13(){
	speak "Aspetta! Anch'io sono molto bravo! Voi sapete fare così?"
	sleep 5.0
	look_nose_iKinRel 
	sleep 5.0
	speak "#LAUGH02#"
	go_home

}

q14(){
	i
	speak "Perché ho la faccia bianca? E perché le sopracciglia e la bocca fluuo?" #Per far vedere meglio i led che ti consentono di mostrare le tue espressioni facciali
  	sleep 5.0
	c
}

spiega(){
	c
	speak "Ora i miei colleghi risponderanno alle domande che gli avete mandato"
	head_breathers
	sleep 4.0
}



#######################################################################################
# "MAIN" FUNCTION:                                                                    #
#######################################################################################
list() {
	compgen -A function
}

echo "********************************************************************************"
echo ""

$1 "$2"

if [[ $# -eq 0 ]] ; then
    echo "No options were passed!"
    echo ""
    usage
    exit 1
fi

