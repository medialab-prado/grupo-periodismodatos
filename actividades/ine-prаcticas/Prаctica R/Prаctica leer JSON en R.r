###############################################################
####### PRÁCTICA: LECTURA DE SW JSON PARA TRATARLO EN R #######
###############################################################


################################################################
############# PRÁCTICA: LIBRERÍAS R PARA LEER JSON #############
################################################################

### 1. LECTURA Y ALMACENAJE DE INFORMACIÓN ###
# Leer datos de las funciones SERIE, VALORES_SERIES y DATOS_SERIE para
	# la serie que recoge el total de pernoctaciones en alojamientos 
	# de turismo rural de residentes en el extranjero para turismo rural
# Almacenar la información en una lista: 
	# El primer elemento con la información de la serie. 
	# El segundo, con los metadatos que definen la serie. 
	# El tercero, una tabla con las siguientes columnas: 
		# Periodo | Año | Tipo_Dato | Valor 

### 2. REPRESENTACIÓN DE INFORMACIÓN ###
# Hacer un gráfico de puntos y líneas y en el que los puntos cambien de
	# color en función del tipo de dato. 
# El título del gráfico estará almacenado en el primer objeto de la lista. 
# Los ejes, periodo en abscisas, unidades en las ordenadas. 


################################################################
################################################################
################################################################



###################################################################
############ 1. LECTURA Y ALMACENAJE DE LA INFORMACIÓN ############
###################################################################


################################################
### Sobre las librerías que vamos a utilizar ###
################################################


# Instalación de las librerías necesarias. 
library(jsonlite)
library(RJSONIO)
library(rjson)
library(curl)	
library(scales)
library(stringr)
library(ggplot2)

# Si no se han instalado las librerías correctamente, elegirlas de entre el listado
	# que aparece al ejecutar:
utils:::menuInstallPkgs()


### Información y descarga de las librerías:
	# https://cran.r-project.org/web/packages/RJSONIO/index.html
	# https://cran.r-project.org/web/packages/rjson/index.html  
	# https://cran.r-project.org/web/packages/jsonlite/index.html
	# https://cran.r-project.org/web/packages/curl/index.html
	# https://cran.r-project.org/web/packages/scales/index.html
	# https://cran.r-project.org/web/packages/stringr/index.html
	# https://cran.r-project.org/web/packages/ggplot2/index.html


# Leer JSON de una URL:
# La función "fromJSON" requiere como parámetro de entrada una URL. 
# Consideramos la información de la serie y datos del total de pernoctaciones en alojamientos 
	# de turismo rural de residentes en el extranjero dentro de la EOTR:
	# http://servicios.ine.es/wstempus/js/ES/DATOS_SERIE/EOT1147?nult=24

	
nult<-24 	# Número de datos que se quiere recuperar de la serie
	
					########################################
					####### ELEGIR UNA DE LAS SERIES #######
					########################################

### SERIE MENSUAL ###
cod_serie<-"EOT1147"
nombre_variable_estudio<-"Pernoctaciones"

### SERIE TRIMESTRAL ###
cod_serie<-"ETCL13726"
nombre_variable_estudio<-"Coste_total_por_trabajador"

### SERIE SEMESTRAL ###
cod_serie<-"CP335"
nombre_variable_estudio<-"Población_residente"

### SERIE ANUAL ###
cod_serie<-"IDB37106"
nombre_variable_estudio<-"Fecundidad"

					########################################
					########################################
					########################################


SERIE_API<-paste("http://servicios.ine.es/wstempus/js/ES/SERIE/",cod_serie,sep="")
METADATOS_SERIE_API<-paste("http://servicios.ine.es/wstempus/js/ES/VALORES_SERIE/",cod_serie,sep="")
DATOS_SERIE_API<-paste("http://servicios.ine.es/wstempus/js/ES/DATOS_SERIE/",cod_serie,"?nult=",nult,"&det=2",sep="")


# El contenido los objetos que acabamos de crear es la URL. 
SERIE_API
METADATOS_SERIE_API
DATOS_SERIE_API


# Guardar el contenido de la URL en un objeto con formato R para poder ser tratado. 
# Ayuda de las funciones fromJSON de las diferentes librerías que hemos descargado: 
?fromJSON


### Utilizamos fromJSON de la librería "RJSONIO" ###	
info_serie<-RJSONIO::fromJSON(SERIE_API,encoding = "UTF-8")
metadatos_serie<-RJSONIO::fromJSON(METADATOS_SERIE_API,encoding = "UTF-8")
datos_serie<-RJSONIO::fromJSON(DATOS_SERIE_API,encoding = "UTF-8")



############################################
### Objetos obtenidos de la lectura JSON ###
############################################


# Los objetos creados en R son de tipo lista.  
class(info_serie)
class(metadatos_serie)
class(datos_serie)
# Los elementos datos_serie, a su vez, listas.
datos_serie[[1]]
class(datos_serie[[1]])


# Veamos el contenido de cada elemento de la lista. 


	###############################
	### Información de la serie ###
	###############################

info_serie
# Es una lista. Se puede acceder a cada uno de los elementos:
	# Por su posición
info_serie[[3]]	
	# Por su nombre
info_serie$COD	
	
# Para ver los nombres: 
names(info_serie)

# Comparamos con la salida JSON que está leyendo. 
# Copiamos la URL contenida en SERIE_API en el navegador: 
SERIE_API


	#############################
	### Metadatos de la serie ###
	#############################

metadatos_serie
names(metadatos_serie)
# Es una lista que a su vez contiene listas que tienen los mismos elementos.
# Veamos el primero de ellos
metadatos_serie[[1]]
names(metadatos_serie[[1]])

# Comparamos con la salida JSON que está leyendo. 
# Copiamos la URL contenida en METADATOS_SERIE_API en el navegador: 
METADATOS_SERIE_API



	#########################
	### Datos de la serie ###
	#########################
datos_serie
# Análogo a medatados_serie

# Comparamos con la salida JSON que está leyendo. 
# Copiamos la URL contenida en DATOS_SERIE_API en el navegador: 
DATOS_SERIE_API

 
# Las diferencias entre los tres objetos creados (info_serie, metadatos_serie, datos_serie) 
	# se debe a la estructura de la salida JSON, ya hemos visto las diferencias entre ellas.  




############################################
###### Formateo de los objetos creados #####
############################################


# Construimos un objeto de tipo lista, llamado SERIE, con el formato y estructura que nos interese. 
SERIE<-list()

# En este objeto vamos a guardar las características de la serie (info y metadatos) y los datos. 


	#############################################################
	### Primera dimensión SERIE[[1]]: Información de la serie ###
	#############################################################
	
# Visualizamos las dimensiones para saber las que vamos a seleccionar y en qué posición se encuentran: 
t(names(info_serie))

# Cómo las vamos a ordenar:
orden_info<-c(5,2,4,7,10,11,6)
SERIE[[1]]<-t(as.data.frame(t(info_serie[orden_info])))
SERIE


	###########################################################
	### Segunda dimensión SERIE[[2]]: Metadatos de la serie ###
	###########################################################
	
# Variables y valores que definen la serie. 
# Van a estar contenidos en un data frame, porque en la "tabla" que vamos a contruir 
	# se mezclan valores numéricos y valores de texto. 
# Visualizamos las dimensiones del primer elemento para saber las que vamos a seleccionar 
	# de todos ellos y en qué posición se encuentran: 
t(names((metadatos_serie[[1]])))

# La información que nos queremos llevar entonces es...
orden_metadatos<-c(2,1,3)
metadatos_serie[[1]][orden_metadatos]
# ... pero de todos los metadatos.

# Cuántas listas tiene metadatos_serie
length(metadatos_serie)

# Construimos la segunda dimensión de serie, de momento con la primera variable-valor:
SERIE[[2]]<-data.frame(t(metadatos_serie[[1]][orden_metadatos]))

# Ahora para todos los metadatos que definen la serie. 
for (i in 2:length(metadatos_serie)) {
	SERIE[[2]][i,]<-data.frame(t(metadatos_serie[[i]][orden_metadatos]))
	}
SERIE



	####################################################################
	### Tercera dimensión SERIE[[3]]: nult últimos datos de la serie ###
	####################################################################
	
# En la tercera dimensión de la lista, los datos de la serie. 
# Al igual que la segunda, ésta va a ser un data frame.
# Visualizamos las dimensiones para saber las que vamos a seleccionar y en qué posición se encuentran: 

t(names(datos_serie$Data[[1]]$TipoDato))
t(names(datos_serie$Data[[1]]$Periodo))
t(names(datos_serie$Data[[1]]))

# La información que nos queremos llevar entonces es...

datos_serie$Data[[1]]$TipoDato <- as.character(datos_serie$Data[[1]]$TipoDato[2])

datos_serie$Data[[1]]$Periodo <- as.character(datos_serie$Data[[1]]$Periodo[7])

orden_datos<-c(3,4,2,7)

# ...pero de todos los datos devueltos.

# Tenemos que almacenarlos todos: 
SERIE[[3]]<-data.frame(t(datos_serie$Data[[1]][orden_datos]))

if (nult>1) {
	i<-2	# Empezamos en el segundo dato porque el primero ya lo hemos guardado
	for (i in 2:nult) {
		datos_serie$Data[[i]]$TipoDato <- as.character(datos_serie$Data[[i]]$TipoDato[2])
		datos_serie$Data[[i]]$Periodo <- as.character(datos_serie$Data[[i]]$Periodo[7])
		SERIE[[3]][i,]<-data.frame(t(datos_serie$Data[[i]][c(3,4,2,7)]))
		i<-i+1
		}
	}


##########################################
### Mejora de la presentación de SERIE ###
##########################################

# Vemos cómo ha quedado el objeto SERIE
SERIE

	#################################
	### Renombrar las dimensiones ###
	#################################

# Primero damos nombres a las dimensiones de SERIE
names(SERIE)<-c("INFO","METADATOS","DATOS")

# Visualizamos los nuevos nombres. 
SERIE

# Tipos de los objetos que contien la lista SERIE
class(SERIE)
lapply(SERIE,class) 


	########################
	### Formateo de INFO ###
	########################
dimnames(SERIE$INFO)<-"---------------- Información de la serie (devuelve el nombre de las dimensiones ---------------"
SERIE$INFO

		#########################################
		### Dar nombres a los códigos Tempus3 ###
		#########################################
	
# Se pueden "traducir" ciertos códigos Tempus3 que aparecen en SERIE:
operaciones<-RJSONIO::fromJSON("http://servicios.ine.es/wstempus/js/ES/OPERACIONES_DISPONIBLES",encoding = "UTF-8")
periodicidades<-RJSONIO::fromJSON("http://servicios.ine.es/wstempus/js/ES/PERIODICIDADES",encoding = "UTF-8")
escalas<-RJSONIO::fromJSON("http://servicios.ine.es/wstempus/js/ES/ESCALAS",encoding = "UTF-8")
unidades<-RJSONIO::fromJSON("http://servicios.ine.es/wstempus/js/ES/UNIDADES",encoding = "UTF-8")

# Sustituimos los códigos por su nombre: 

	### Operación
operacion_serie<-NULL
i<-1

while (is.null(operacion_serie) && i<=length(operaciones)) { 
	if (operaciones[[i]]$Id==SERIE$INFO["FK_Operacion",]) {
		operacion_serie<-operaciones[[i]]$Nombre
		SERIE$INFO["FK_Operacion",]<-operacion_serie
	}
	i=i+1
}

# Guardamos el código de la periodicidad y su código para poder utilizarlo más adelante
fk_periodicidad<-SERIE$INFO["FK_Periodicidad",][[1]]
	
	### Periodicidad 
periodicidad_serie<-NULL
i<-1

while (is.null(periodicidad_serie) && i<=length(periodicidades)) { 
	if (periodicidades[[i]]$Id==SERIE$INFO["FK_Periodicidad",]) {
		periodicidad_serie<-periodicidades[[i]]$Nombre
		cod_periodicidad<-periodicidades[[i]]$Codigo
		SERIE$INFO["FK_Periodicidad",]<-periodicidad_serie
	}
	i=i+1
}
	
	### Escala
escala_serie<-NULL
i<-1

while (is.null(escala_serie) && i<=length(escalas)) { 
	if (escalas[[i]]$Id==SERIE$INFO["FK_Escala",]) {
		escala_serie<-escalas[[i]]$Nombre
		SERIE$INFO["FK_Escala",]<-escala_serie
		if (escala_serie==" ") {SERIE$INFO["FK_Escala",]<-"Unidad"}
	}
	i=i+1
}

	
	### Unidad
unidad_serie<-NULL
i<-1

while (is.null(unidad_serie) && i<=length(unidades)) { 
	if (unidades[[i]]$Id==SERIE$INFO["FK_Unidad",]) {
		unidad_serie<-unidades[[i]]$Nombre
		SERIE$INFO["FK_Unidad",]<-unidad_serie
	}
	i=i+1
}

	
# Cambiamos los nombres de las dimensiones
	# De la información de la serie
dimnames(SERIE[[1]])[[1]]<-c("Nombre","Código","Operación","Periodicidad","Escala","Unidad","NºDecimales")

# Vemos cómo ha quedado INFO
SERIE$INFO



	#############################
	### Formateo de METADATOS ###
	#############################

# Veamos el aspecto de SERIE$METADATOS
SERIE$METADATOS

# Nos falta recoger el nombre de las variables. 
# Primero se crea una columna que almacene el nombre de la variable. 
SERIE$METADATOS["new.col"]<-"nombre_variable"
SERIE$METADATOS<-SERIE$METADATOS[c(1,4,2,3)]

# Ahora renombramos las columnas. 
dimnames(SERIE[[2]])[[2]]<-c("Id_Variable","Variable", "Id_Valor","Valor") 
SERIE$METADATOS


# Buscamos el nombre de las variables y rellenamos la columna que falta. 
for (i in 1:length(SERIE$METADATOS[[1]])) {
	variable<-RJSONIO::fromJSON(paste("http://servicios.ine.es/wstempus/js/ES/VARIABLE/",SERIE$METADATOS[i,"Id_Variable"],sep=""),encoding = "UTF-8")
	SERIE$METADATOS[i,"Variable"]<-variable$Nombre
	i<-i+1
}

# Vemos cómo ha quedado
SERIE$METADATOS


	#########################
	### Formateo de DATOS ###
	#########################
	
	# Cambiamos los nombres de las columnas 
	# De la información de datos
dimnames(SERIE[[3]])[[2]]<-c("Periodo", "Año","Tipo_Dato", "Valor")

SERIE$DATOS


	###########################################################
	### Visualización del objeto SERIE después del formateo ###
	###########################################################


# ************************************************************************************ #
# ************************************************************************************ #
# ************************************************************************************ #
# ************************************************************************************ #



######################################################################
################## 2. REPRESENTACIÓN DE INFORMACIÓN ##################
######################################################################


# Librerías necesarias para hacer el gráfico. 
require(scales) 
require(stringr)
require(ggplot2)

# Dataframe que contiene la información necesaria para realizar el gráfico. 
if (fk_periodicidad==12) {
	df.grafico<-data.frame("Datos"=as.numeric(SERIE$DATOS$Valor),
							"Periodo"= as.numeric(t(t(SERIE$DATOS[,"Año"]))),
							"Tipo"= as.character(SERIE$DATOS[,3]))
	dimnames(df.grafico)[[2]][1]<-nombre_variable_estudio
		
} else {
	if (fk_periodicidad==1 || fk_periodicidad==3){
		df.grafico<-data.frame("Datos"=as.numeric(SERIE$DATOS$Valor),
							"Periodo"= paste(SERIE$DATOS[,1],SERIE$DATOS[,"Año"],sep=" "),
							"Tipo"= as.character(SERIE$DATOS[,3]))
		dimnames(df.grafico)[[2]][1]<-nombre_variable_estudio
	} else {
		df.grafico<-data.frame("Datos"= as.numeric(SERIE$DATOS$Valor),
							"Periodo"= paste(SERIE$DATOS[,"Año"],SERIE$DATOS[,1],sep=""),   
							"Tipo"= as.character(SERIE$DATOS[,3]))
		dimnames(df.grafico)[[2]][1]<-nombre_variable_estudio
	}
}

df.grafico

# El periodo lo consideramos un factor, para categorizar los datos. 
df.grafico$Periodo<-factor(df.grafico$Periodo, levels=rev(df.grafico$Periodo))

# Título del gráfico
titulo<-str_replace_all(paste(SERIE$INFO["Código",],": ",SERIE$INFO["Nombre",],". ",SERIE$INFO["Operación",],sep="\n"),"[[:punct:]]", " ")

# Gráfico con todas las opciones de dibujo

g= ggplot(df.grafico, aes(x=Periodo,y=Pernoctaciones # Este parámetro "y" habrá que cambiarlo de nombre en 
														# función de cómo se llame la primera columna de df.grafico
		,group = Tipo)) + 
  geom_point(aes(color=Tipo, shape=Tipo),size=3) +  
  geom_line(aes(group=1, color=Tipo),size=0.7) +
  scale_color_manual(values=c("green", "orange")) +
  ggtitle(titulo) +
  theme(plot.title=element_text(face="bold",size=15)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels=function(x) format(x, big.mark = ".", decimal.mark=",", scientific = FALSE))  
  
  
# Para guardar el gráfico en un pdf: Se creará el archivo en el directorio establecido como espacio de trabajo. 
g = ggplot(df.grafico, aes(x=Periodo,y=Pernoctaciones  # Este parámetro "y" habrá que cambiarlo de nombre en 
														# función de cómo se llame la primera columna de df.grafico
		,group = Tipo)) + 
  geom_point(aes(color=Tipo, shape=Tipo),size=3) +  
  geom_line(aes(group=1, color=Tipo),size=0.7) +
  scale_color_manual(values=c("green", "orange")) +
  ggtitle(titulo) +
  theme(plot.title=element_text(face="bold",size=15)) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels=function(x) format(x, big.mark = ".", decimal.mark=",", scientific = FALSE))   
pdf("plot.pdf",paper='a4')
g
dev.off() 





