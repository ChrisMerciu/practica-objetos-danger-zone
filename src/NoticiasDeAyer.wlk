
const hoy = new Date()
const dosDiasAtras = hoy.minusDays(2)
const ultimaSemana = hoy.minusDays(7)
const haceUnAno = hoy.minusYears(1)
class Noticia{
    const property fechaDePublicacion
    var property personaQueLaPublico = "nadie"
    const property gradoDeImportancia
    const property titulo
    const property cantidadDePalabrasDeDesarrollo 

    method noticiaImportante() = self.gradoDeImportancia() >= 8
    method publicadaHaceMenosDeTresDias() = self.fechaDePublicacion().between(dosDiasAtras, hoy)

    method noticiaCopada() = self.noticiaImportante() && self.publicadaHaceMenosDeTresDias()
    method noticiaSensacionalista() = self.titulo().contains("espectacular") || self.titulo().contains("increíble") || self.titulo().contains("grandioso") 
    method noticiaParaVagos() = self.esChivo() || self.cantidadDePalabrasDeDesarrollo() < 100
    method noticiaT() = self.titulo().take(1) == "T"

    method publicarNoticia(periodista){
        personaQueLaPublico = periodista
    }

    method esChivo() = false
}

class ArticulosComunes inherits Noticia{
    const property linksAOtrasNoticias

    override method noticiaCopada() = super() && linksAOtrasNoticias.size() >= 2 
}

class Chivo inherits Noticia{
    const property plataPagada

    override method noticiaCopada() = super() && plataPagada > 2000000
    override method esChivo() = true
}

class Reportaje inherits Noticia{
    const property personaReportada

    method nombreImpar() = personaReportada.length() % 2 == 0

    override method noticiaCopada() = super() && self.nombreImpar()
    override method noticiaSensacionalista() = super() && personaReportada == "Dibu Martínez"
}

class Cobertura inherits Noticia{
    const property noticiasRelacionadas

    override method noticiaCopada() = super()  && noticiasRelacionadas.forEach({ noticia => noticia.noticiaCopada()})
}


// -------------------------------------- Punto 2 --------------------------------------------
// Punto 3 B sin hacer
class Periodista{
    const property fechaDeIngreso
    const property preferencia 
    const property noticiasPublicadas

    method publicarNoticia(noticia){
        if (preferencia.publicarNoticiaPreferida(noticia)){
            noticia.publicarNoticia(self)
            noticiasPublicadas.add(noticia)
        } else self.noticiaQueNoPrefiere(noticia)
    }

    method noticiaQueNoPrefiere(noticia){
        if (noticiasPublicadas.filter({ noticia => noticia.fechaDePublicacion() == hoy}).size() < 2){
        noticia.publicarNoticia(self)
        noticiasPublicadas.add(noticia)
        } else self.error("Solo se pueden publicar dos noticias que no se prefieran por día")
    }

    method periodistaReciente() = fechaDeIngreso.between(hoy, haceUnAno)

    method publicaronEstaSemana() = noticiasPublicadas.any({noticia => noticia.fechaDePublicacion().between(hoy, ultimaSemana)})
    
}

object noticiasCopadas{
    method publicarNoticiaPreferida(noticia) = noticia.noticiaCopada()
}

object noticiasSensacionalistas{
    method publicarNoticiaPreferida(noticia) = noticia.noticiaSensacionalista()
}

object vagos{
    method publicarNoticiaPreferida(noticia) = noticia.noticiaParaVagos()
}

object letraT{
    method publicarNoticiaPrederida(noticia) = noticia.noticiaT()
}


object joseDeZer inherits Periodista( fechaDeIngreso = hoy, preferencia = letraT, noticiasPublicadas = []){

}

class Multimedio{
    var property empleados 

    method periodistasRecientes() = empleados.forEach{empleado => empleado.periodistaReciente()}

    method controlDePeriodistasRecientes() = self.periodistasRecientes().filter({periodista => periodista.publicaronEstaSemana()})
}