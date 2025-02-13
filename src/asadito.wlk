class Persona{
    var property posicion
    var property elementosQueTieneCerca = []
    var property criterio
    var property comidaElegida = []
    var property formaDeElegirComida 

    method preguntarPorElementoA(persona, elemento){
        var elementoPasado
        if(persona.tieneCerca(elemento)){
            elementoPasado = persona.pasarElemento(elemento)
            self.recibirElemento(elementoPasado)
            persona.perderElemento(elementoPasado)
        }
        else self.error("La persona no tiene ese elemento cerca")
    }

    method tieneCerca(elemento) = elementosQueTieneCerca.contains(elemento)

    method pasarElemento(elemento) = criterio.pasarElemento(self, elemento)

    method recibirElemento(elemento) = elementosQueTieneCerca.addAll(elemento)

    method perderElemento(elemento) = elementosQueTieneCerca.remove(elemento)

    method cambiarDePosicion(persona){
        var nuevaPosicion = persona.posicion()
        persona.posicion(self.posicion())
        posicion = nuevaPosicion
        self.cambiarDeElementos(persona)
    }

    method cambiarDeElementos(persona){
        var nuevosElementos = persona.elementosQueTieneCerca()
        persona.elementosQueTieneCerca(self.elementosQueTieneCerca())
        elementosQueTieneCerca = nuevosElementos
    }

    method comerComida(comida) {
        formaDeElegirComida.quiereComer(comida)
        comidaElegida.add(comida)
    }

    method estaPipon() = comidaElegida.any({ comida => comida.calorias() > 500 })

    method laEstaPasandoBien() = self.comidaElegida().size() >= 1

}

object sordo {
    method pasarElemento(persona, elemento) = persona.elementosQueTieneCerca().take(1)
}

object pasarTodos{
    method pasarElemento(persona, elemento) {
        var elementosPasados
        elementosPasados = persona.elementosQueTieneCerca()
        persona.elementosQueTieneCerca().clear()
        return elementosPasados
    }
}

object cambiarPosicion{
    method pasarElemento(persona, elemento) {
        persona.cambiarDePosicion(persona)
        return []}
}

object personaNormal{
    method pasarElemento(persona, elemento) {
        persona.perderElemento(elemento)
        return elemento
    }
}

const persona4 = new Persona(posicion = "izquierda", elementosQueTieneCerca = ["afiladora", "verdura"], criterio = personaNormal, formaDeElegirComida = "vegetariano")

// ------------------------------------- Punto 2 -------------------------------------------

class BandejaDeComida{
    const property calorias
    var property esCarne = true

}

object vegetariano{
    method quiereComer(comida) = not(comida.esCarne())
}

object dietetico{
    method quiereComer(comida) = comida.calorias() < 500
}

object alternado{
    var aceptoComida = false

    method quiereComer(comida) {
     if (not(aceptoComida)){
        aceptoComida = true
        return aceptoComida
     } else return aceptoComida
    }
}

object combinado{
    method quiereComer(comida) = vegetariano.quiereComer(comida) && dietetico.quiereComer(comida) && alternado.quiereComer(comida)
}

object osky inherits Persona(posicion = "1@2", elementosQueTieneCerca = ["sal", "pimienta"], criterio = sordo, formaDeElegirComida = dietetico){
    override method laEstaPasandoBien() = true
}

object moni inherits Persona(posicion = "1@1", elementosQueTieneCerca = ["mostaza", "ketchup"], criterio = cambiarPosicion, formaDeElegirComida = vegetariano){
    override method laEstaPasandoBien() = super() && self.posicion() == "1@1"
}

object facu inherits Persona(posicion = "1@3", elementosQueTieneCerca = ["cuchillo", "carne"], criterio = pasarTodos, formaDeElegirComida = alternado){
    override method laEstaPasandoBien() = super() && self.comioCarne()

    method comioCarne() = comidaElegida.any({comida => comida.esCarne()})
}

object vero inherits Persona(posicion = "izquierda", elementosQueTieneCerca = ["afiladora", "verdura"], criterio = personaNormal, formaDeElegirComida = combinado){
    override method laEstaPasandoBien() = super() && self.tieneMenosDe3Elementos()

    method tieneMenosDe3Elementos() = elementosQueTieneCerca.size() <= 3
}