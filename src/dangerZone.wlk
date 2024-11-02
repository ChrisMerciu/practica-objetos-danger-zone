class Empleado{
    var property puesto
    var salud = 100
    const habilidades = #{}

    method estaIncapacitado() = salud < puesto.saludCritica()

    method puedeUsar(habilidad) = not self.estaIncapacitado() && self.poseeHabilidad(habilidad)

    method poseeHabilidad(habilidad) = habilidades.contains(habilidad)

    method recibirDanio(cantidad) { salud = salud - cantidad }

    method estaVivo() = salud > 0

    method finalizarMision(mision) {
        if (self.estaVivo()) {
            self.completarMision(mision)
        }
    }

    method completarMision(mision) {
        puesto.completarMision(mision)
    }

    method aprenderHabilidad(habilidad) {
        habilidades.add(habilidad)
    }
}

class Equipo {
    const empleados = []

    method puedeUsar(habilidad) = empleados.any({empleado => empleado.puedeUsar(habilidad)})

    method recibirDanio(cantidad) {
        empleados.forEach({empleado => empleado.recibirDanio(cantidad / 3)})
    }
    method finalizarMision(mision) {
        empleados.forEach({empleado => empleado.finalizarMision(mision)})
    }
}


class Mision {
    const habilidadesRequeridas = []
    const peligrosidad

    method serCumplidaPor(asignado) {
        self.validarHabilidades(asignado)
        asignado.recibirDanio(peligrosidad)
        asignado.finalizarMision(self)
    }

    method validarHabilidades(asignado) {
        if (not self.reuneHabilidadesRequeridas(asignado)) {
            self.error("La misión no se puede cumplir")
        }
    }

    method enseniarHabilidades(empleado) {
        self.habilidadesQueNoPosee(empleado).forEach({hab => empleado.aprender(hab)})
    }

    method reuneHabilidadesRequeridas(asignado) = habilidadesRequeridas.all({hab => asignado.puedeUsar(hab)})

    method habilidadesQueNoPosee(empleado) = habilidadesRequeridas.filter({hab => not empleado.poseeHabilidad(hab)})
}

class Jefe inherits Empleado {
    var subordinados

    override method poseeHabilidad(habilidad) =
        super(habilidad) || self.algunoDeSusSubordinadosLaPuedeUsar(habilidad)

    method algunoDeSusSubordinadosLaPuedeUsar(habilidad) =
        subordinados.any {subordinado => subordinado.puedeUsar(habilidad)}
}

object espia {
    method saludCritica() = 15

    method completarMision(mision, empleado){
        mision.enseniarHabilidades(empleado)
    }
}

class Oficinista{
    var cantEstrellas = 0

    method saludCritica() = 40 - 5 * cantEstrellas

    method completarMision(mision, empleado){
        cantEstrellas += 1
        if (cantEstrellas == 3) {
            empleado.puesto(espia)
        }
    }
}