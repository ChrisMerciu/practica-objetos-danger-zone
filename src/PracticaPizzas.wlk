
class Pizza{
    const masaInicial
    var masaFinal = masaInicial
    var gradoDeCoccion
    const ingredientes

    method agregarIngrediente(ingrediente) = ingredientes.add(ingrediente)

    method cocinarPor(minutos) {
        gradoDeCoccion += minutos * (10/masaFinal)
        masaFinal -= minutos * (masaInicial * 0.01)
    }

    method masaInicial() = masaInicial

    method masa() = masaFinal

    method coccion() = gradoDeCoccion

    method ingredientesDePizza() = ingredientes

    method estaCruda() = gradoDeCoccion < 0.4

    method estaQuemada() = gradoDeCoccion > 1.0

    method estaCargada() = ingredientes != ingredientes.withoutDuplicates()

    method tieneIngrediente(ingredienteBuscado) = ingredientes.contains(ingredienteBuscado)

}

class Pizzero {
    var pizza = self.hacerPrePizza()

    method hacerPrePizza() = new Pizza(masaInicial = 500, gradoDeCoccion = 0.3, ingredientes = ["tomate"])

    method hacerPizza() {
        pizza.agregarIngrediente("muzzarella")
        pizza.cocinarPor(10)
    }

    method pizza() = pizza
}

object carla inherits Pizzero {
  override method hacerPizza(){
    pizza.agregarIngrediente("provolone")
    pizza.cocinarPor(1)
    super()
  }
}

object facu inherits Pizzero {
    var humor = "arriesgado"

    method cambiarHumor(humorNuevo){
        humor = humorNuevo
    }

    method agregarSegunHumor(){
        if(humor == "arriesgado"){
            pizza.agregarIngrediente("anana")
        }
        else{
            pizza.agregarIngrediente("oregano")
        }
    }

    override method hacerPizza(){
        self.agregarSegunHumor()
        super()
    }
}

class PizzeroMaritimo inherits Pizzero {
    var ingredienteFavorito
    
    override method hacerPrePizza() =  new Pizza(masaInicial = 650,ingredientes = ["tomate"],gradoDeCoccion = 0.3)

    override method hacerPizza() {
       pizza.agregarIngrediente(ingredienteFavorito)
       pizza.agregarIngrediente(pizzeriaMaritima.ingredienteDelDia())
        super()
    }
}

object pizzeriaMaritima{
    var property ingredienteDelDia = "jamon"
}

class Juez {
    var ingredienteQueNoGusta

    method pizzaVetable(pizza) = self.tieneUnIngredienteNoGustado(pizza) || pizza.estaCruda()
    method tieneUnIngredienteNoGustado(pizza) = pizza.tieneIngrediente(ingredienteQueNoGusta)

    method puntuarPizza(pizza)
    method juzgarPizza(pizza) = 1.min(0.max(self.puntuarPizza(pizza)))
}

object zeff inherits Juez(ingredienteQueNoGusta="atun") {
    override method puntuarPizza(pizza) {
        return pizza.masa()/pizza.masaInicial()
    }

}

object anton inherits Juez(ingredienteQueNoGusta="morrones") {
    override method pizzaVetable(pizza) = super(pizza) || pizza.masa() < 400
    override method puntuarPizza(pizza) {
        var puntaje = 1
        if(pizza.estaQuemada()){
            puntaje -=0.5
        }
        else if(pizza.estaCargada()){
            puntaje+=0.2
        }
        return puntaje - self.cantidadMayorA500(pizza)*0.1
    }
    method cantidadMayorA500(pizza) = (0.max(pizza.masa()-500)/100).coerceToInteger()
}

object contrera inherits Juez(ingredienteQueNoGusta="quesoAzul") {
    var ingredienteQueLeGusta = "anana"
    var referente = zeff
    method cambiarReferente(nuevoReferente) {
      referente = nuevoReferente
    }
    override method puntuarPizza(pizza) {
        var puntaje = 1
        if(pizza.tieneIngrediente(ingredienteQueLeGusta)){
            puntaje +=0.2
        }
        return puntaje - referente.puntuarPizza(pizza)
    }
}


class Concurso {
    const pizzerosConcursantes = new List()
    const jurado = new List()

    method iniciarConcurso() {
        //preparan la pizza
        pizzerosConcursantes.forEach({pizzero => pizzero.hacerPizza()})
        //ronda de vetos
        const pizzerosPasables = self.rondaVetos() 
        //evaluan las pizzas
        const puntajesPizzas = self.puntuarPizzas(pizzerosPasables)
        //a ver si hay empate
        self.hayEmpate(puntajesPizzas)
        //seleccionan al pizzero ganador
        return self.encontrarGanador(pizzerosPasables,puntajesPizzas)
    }

    method hayEmpate(puntajes) {
      //si llegase a haber empate no hay ganador posible
      //si el ultimo y el anteultimo son iguales
      if (puntajes.get(puntajes.size()-2)==puntajes.last()){ 
            self.error("No hay ganador posible")
      }
    }

    method rondaVetos() {
      //dejo a los pizzeros no vetadas
      const pizzerosNoVetados = pizzerosConcursantes.filter(
        {pizzero => jurado.all({juez => !juez.pizzaVetable(pizzero.pizza())})}
        )
      //si todos los pizzeros fueron vetados, no hay ganador posible
      if(pizzerosNoVetados.isEmpty()){
        self.error("No hay ganador posible")
      }
      return pizzerosNoVetados
    }

    method puntuarPizzas(pizzerosPasables) {
        //consigo las pizzas
        const pizzas = pizzerosPasables.map({pizzero=>pizzero.pizza()})
        //consigo los puntaje de cada pizza
        const puntajesXPizza = pizzas.map({pizza=>jurado.map({juez=>juez.juzgarPizza(pizza)})})//sum no funcionaba
      //sumo los puntajes de cada pizza, 
      const puntajesPizza = puntajesXPizza.map({puntajes=>puntajes.sum()})
      //lo ordeno MenMay para luego evaluar empate
      return puntajesPizza.sortedBy{n1,n2=>n1<n2}
    }

    method encontrarGanador(pizzerosPasables,puntajes) {
      //buscar en los pizzeros el pizzero con la piza  
      //que tiene el puntaje igual al mas alto
      return pizzerosPasables.filter({pizzero=>jurado.map({juez=>juez.juzgarPizza(pizzero.pizza())}).sum()==puntajes.max()}).anyOne()//no funcionaba take o get
    }
}