var tablaURL = "http://servicios.ine.es/wstempus/js/ES/DATOS_TABLAOPERACION/1432/33?nult=5&det=2";
var categURL = "http://servicios.ine.es/wstempus/js/ES/VALORES_SERIE/";
var urlMeta = "";
var obj;
var tablaDatos = new Array();
var periodos = new Array();

function cargadatos(){
	$.ajaxSetup({
		async: false
	});
	$.getJSON(tablaURL,function(data){
	})
	.done(function(data) {
		if(data==null || data.length===0){

		}else{	
			// Para cada serie de datos
			$.each( data, function(i, itemSerie) {
				obj = null;
				// Construyo la url JSON de metadatos de la serie
				urlMeta = categURL + itemSerie.COD;
				
				// Hago la llamada y me quedo con el valor de la variable 95
				$.getJSON(urlMeta,function(data){
				})
				.done(function(data) {
					if(data==null || data.length===0){

					}else{					
						$.each( data, function(j, itemMeta) {
							if (itemMeta.Fk_Variable == 70){ // Variable Comunidades Autónomas
								obj = new Fila(itemMeta.Nombre);
							} else
							if (itemMeta.Fk_Variable == 349){ // Variable con el Total Nacional
								obj = new Fila(itemMeta.Nombre);
							}
						});
					}
				});
				
				if (obj!=null){
					// Relleno la fila de datos
					$.each(itemSerie.Data, function(k, itemValor){
						obj.datos.push(new Valor(itemValor.Valor, itemValor.CodigoPeriodo));
						if (i==0) // Solo con la primera serie, relleno el array de periodos
							periodos.push(itemValor.NombrePeriodo);
					});
					
					// Añadimos la fila a la matriz
					tablaDatos.push(obj);
				}
				
			});
		}
	});
	$.ajaxSetup({
		async: true
	});
}

function Fila (nombre){
	this.categ = nombre;
	this.datos = new Array();
}

function Valor (dato, periodo){
	this.dato = dato;
	this.periodo = periodo;
}