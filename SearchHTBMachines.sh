#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"



function ctrl_C() {
    echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
    tput cnorm && exit 1
    
}

# Ctrl+c
trap ctrl_C INT

#variables globales
main_url="https://htbmachines.github.io/bundle.js"


function helpPanel (){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"

  echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de maquina ${endColour}"
 
  echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por IP de  la maquina ${endColour}"

  echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por Sistema Operativo ${endColour}"
  
  echo -e "\t${purpleColour}y)${endColour}${grayColour} obtener enlace a youtube ${endColour}"
  

  echo -e "\t${purpleColour}d)${endColour}${grayColour} Filtrar por nivel de difucultad ${endColour}"
  
  echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por Skills ${endColour}"
  
  echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar panel de ayuda ${endColour}"
 
  echo -e "\t${purpleColour}u)${endColour}${grayColour} Actualizar archivos necesarios ${endColour}\n"
  }

function updateFiles (){
       tput civis
  if [ ! -f bundle.js ]; then
      
    echo -e "\n${yellowColour} [+] ${endColour} ${grayColour} Descargando archivos necesarios... ${endColour} "
     curl -s $main_url > bundle.js
     js-beautify bundle.js | sponge bundle.js 
  
    echo -e "\n${yellowColour} [+] ${endColour} ${grayColour} Todos los archivos han sido actualizados ${endColour} "
    
  else

     curl -s $main_url > bundle_temp.js
   

    echo -e "\n ${yellowColour} [+] ${endColour} ${grayColour} Verificando actualizaciones... ${endColour} "
     js-beautify bundle_temp.js | sponge bundle_temp.js 
     md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')

     md5_original_value=$(md5sum bundle.js | awk '{print $1}')
     
     if [ "$md5_temp_value" == "$md5_original_value" ]; then
       echo -e  " ${yellowColour} [+] ${endColour} ${greenColour} No hay actualizaciones ${endColour}"
       rm bundle_temp.js
     else
      echo -e "\n ${yellowColour} [+] ${endColour} ${grayColour} Actualizado archivo... ${endColour} "
      sleep 2 
      echo -e "\n ${yellowColour} [+] ${endColour} ${greenColour} El archivo ha sido actualizado ${endColour} \n "
     rm bundle.js && mv bundle_temp.js bundle.js
     fi 
     tput cnorm
    # echo -e "\n ${yellowColour} [+] ${endColour} ${greenColour} El archivo esta actualizado ${endColour} \n "
    
  fi
}

function searchMachine(){
  machineName="$1"

   machineNameCheck="$(cat bundle.js  | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id: | sku: | resuelta:" | tr -d '"' | tr -d ',' | sed  's/^ *//')"
  
   if [ "$machineNameCheck" ]; then

   echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la maquina ${endColour}${blueColour}$machineName${endColour}${grayColour}: ${endColour}  \n "

 cat bundle.js  | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id: | sku: | resuelta:" | tr -d '"' | tr -d ',' | sed  's/^ *//'

else
  echo -e "\n${redColour} [!] La maquina proporcionada no existe ${endColour} \n"
fi
}


function searchIP(){
  ipAddress="$1"

  
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  
  if [ "$machineName" ]; then

  echo -e "\n [+] La maquina correspondiente para la IP $ipAddress es  $machineName\n"
 else
  
  echo -e "\n${redColour} [!] La IP proporcionada no existe ${endColour} \n"
 fi
}

function getYoutubeLink (){
  
   machineName="$1"

   getYoutubeLink="$(cat bundle.js  | awk "/name: \"Tentacle\"/,/resuelta:/" | grep -vE "id: | sku: | resuelta:" | tr -d '"' | tr -d ',' | sed  's/^ *//' | grep youtube | awk 'NF{print $NF}')"

   if [ $getYoutubeLink ]; then
     echo -e "\n${yellowColour}[+]${endColour} El tutorial para resolver esta maquina es este link: ${endColour} ${blueColour} $getYoutubeLink ${endColour}\n "
  else

  echo -e "\n${redColour} [!] La IP proporcionada no existe ${endColour} \n"
   fi
}


function GetsMAchineDificulty (){
 dificulty="$1"

 dificultuCheck="$(cat bundle.js | grep "dificultad: \"$dificulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  
 if [ "$dificultuCheck" ]; then
   echo -e "\n${redColour}[+] Estas son las maquinas con nivel de dificultad:${endColour}${blueColour}  $dificulty ${endColour} \n$dificultuCheck"
  else
   echo -e "\t${purpleColour}[+]${endColour}${grayColour} Esa dificultad no existe ${endColour}"
 fi

}

function GetOperatiomSystem (){

  operationSystem="$1"

 OScheck="$(cat bundle.js | grep "so: \"$operationSystem\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

 if [ "$OScheck" ]; then

   echo -e "\n${redColour}[+] Estas son las maquinas con Sistema Operativo:${endColour}${blueColour}  $operationSystem ${endColour} \n$OScheck"
 else
  

   echo -e "\t${purpleColour}[+]${endColour}${grayColour} No hay maquinas con este Sistema Operativo $operationSystem ${endColour}"
 fi
 }

 function getOSDif (){
   dificulty="$1"
   operationSystem="$2"
 #dificultuCheck="$(cat bundle.js | grep "dificultad: \"$dificulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
 #OScheck="$(cat bundle.js | grep "so: \"$operationSystem\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
 

   OSDif="$(cat bundle.js  |  grep "so: \"$operationSystem\"" -C 4 | grep "dificultad: \"$dificulty\"" -B 5   | grep name   | awk 'NF{print $NF}' | tr -d '"' | tr -d ','  | column )"
 
   if [ "$OSDif" ] ; then
   echo -e "\n${yellowColour}[+] Estas son las maquinas con Sistema operativo ${endColour}${blueColour}  $operationSystem ${endColour} ${yellowColour} y dificultad nivel ${endColour} ${blueColour}$dificulty ${endColour}"

   #OSDif="$(cat bundle.js  |  grep "so: \"$operationSystem\"" -C 4 | grep "dificultad: \"$dificulty\"" -B 5   | grep name   | awk 'NF{print $NF}' | tr -d '"' | tr -d ','  | column )"
   echo $OSDif

 else
   echo -e "\t${purpleColour}[+]${endColour}${grayColour} La dificultad o el OS no existe ${endColour}"
  fi
 }


 function getSkills () {
 skills="$1"

 cheakSkills="$(cat bundle.js  |  grep "skills:" -C 6 | grep "$skills" -i -B 6 | grep "name: " | awk '$NF{print $NF}' | tr -d '"' | tr -d ',' | column
)"

if [ "$cheakSkills" ]; then 


   echo -e "\n${yellowColour}[+] Estas son las maquinas con skills ${endColour}${blueColour}  $skills ${endColour} \n $cheakSkills"

else
  echo -e "\n${redColour}[+] No se encontraron Maquinas con la skill:  $skills ${endColour}"
fi

 }
#indicadoresi
declare -i parameter_counter=0 

#links
declare -i linkParamaterDif=0
declare -i linkParameterOS=0 

while getopts  "m:ui:y:d:o:s:h" arg; do 
 case $arg in
   m) machineName="$OPTARG"; let parameter_counter+=1;; 
   u) let parameter_counter+=2;;
   i) ipAddress="$OPTARG"; let  parameter_counter+=3;;
   y) machineName="$OPTARG"; let parameter_counter+=4;;
   d) dificulty="$OPTARG"; let linkParamaterDif=1; let parameter_counter+=5;;
   o) operationSystem="$OPTARG"; let linkParameterOS=1; let parameter_counter+=6;;
   s) skills="$OPTARG"; let parameter_counter+=7;;
   h);; 
 esac 
done

if [ $parameter_counter  -eq  1 ]; then 
  searchMachine $machineName

elif [ $parameter_counter  -eq 2 ]; then
   updateFiles
 elif [ $parameter_counter -eq 3 ]; then 
  searchIP $ipAddress
 elif [  $parameter_counter -eq 4 ] ; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
GetsMAchineDificulty $dificulty
elif [ $parameter_counter -eq 6 ]; then
  GetOperatiomSystem $operationSystem
elif [ $linkParamaterDif -eq 1 ] && [ $linkParameterOS -eq 1 ]; then
  getOSDif  $dificulty  $operationSystem
elif [ $parameter_counter -eq 7 ]; then
  getSkills "$skills"
else
  helpPanel
fi





