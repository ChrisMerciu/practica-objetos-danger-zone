class Linea {             //LINEA

	const packs = []
	const consumos = []
	var property tipoLinea = comun
	var property deuda = 0

	method gastoMBUltimoMes() = self.gastosEntre(new Date().minusMonths(1), new Date()).sum({ consumo => consumo.cantidadMB() })

	method gastosEntre(min, max) = consumos.filter({ consumo => consumo.consumidoEntre(min, max) })

	method promedioConsumos() = consumos.sum({ consumo => consumo.costo() }) / consumos.size()

	method agregarPack(nuevoPack) {
		packs.add(nuevoPack)
	}

	method puedeRealizarConsumo(consumo) = packs.any({ pack => pack.puedeSatisfacer(consumo) })

	method realizarConsumo(consumo) {
		if (not self.puedeRealizarConsumo(consumo)) tipoLinea.accionConsumoNoRealizable(self, consumo) else self.consumirPack(consumo)
	}

	method consumirPack(consumo) {
		var pack = packs.reverse().find({ pack => pack.puedeSatisfacer(consumo) })
		pack.consumir(consumo)
		consumos.add(consumo)
	}

	method limpiezaPacks() {
		packs.removeAllSuchThat({ pack => pack.esInutil()})
	}

	method sumarDeuda(cantidadDeuda) {
		deuda += cantidadDeuda
	}

}

object platinum {

	method accionConsumoNoRealizable(linea, consumo) {
	}

}

object black {

	method accionConsumoNoRealizable(linea, consumo) {
		linea.sumarDeuda(consumo.costo())
	}

}

object comun {

	method accionConsumoNoRealizable(linea, consumo) {
		self.error("Los packs de la línea no pueden cubrir el consumo.")
	}

}

// ------------------------------------ Consumos ------------------------------------

class Consumo {

	const property fechaRealizado = new Date()

	method consumidoEntre(min, max) = fechaRealizado.between(min, max)

	method cubiertoPorLlamadas(pack) = false

	method cubiertoPorInternet(pack) = false

}

class ConsumoInternet inherits Consumo {

	const property cantidadMB

	method cantidadMinutos() = 0

	method costo() = cantidadMB * pdepfoni.costoMB()

	override method cubiertoPorInternet(pack) = pack.puedeGastarMB(cantidadMB)

	method cantidad() = cantidadMB

}

class ConsumoLlamada inherits Consumo {

	const property segundos

	method cantidadMB() = 0

	method cantidadMinutos() = (segundos / 60).roundUp()

	method costo() = pdepfoni.precioFijoLlamadas() + (self.cantidadMinutos() - 2) * pdepfoni.costoMinuto()

	override method cubiertoPorLlamadas(pack) = pack.puedeGastarMinutos(self.cantidadMinutos())

	method cantidad() = self.cantidadMinutos()

}

object pdepfoni {

	var property costoMB = 0.1
	var property costoMinuto = 1.5
	var property precioFijoLlamadas = 5

}

// -------------------------------------------- PACKS ---------------------------------------------

class Pack {

	const vigencia = ilimitado

	method esInutil() = vigencia.vencido() || self.acabado()

	method acabado()

	method puedeSatisfacer(consumo) = not vigencia.vencido() && self.cubre(consumo)

	method cubre(consumo)

}

class PackConsumible inherits Pack {

	const property cantidad
	const consumos = []

	method consumir(consumo) {
		consumos.add(consumo)
	}

	method cantidadConsumida() = consumos.sum({ consumo => consumo.cantidad() })

	method remanente() = cantidad - self.cantidadConsumida()

	override method acabado() = self.remanente() <= 0

}

class Credito inherits PackConsumible {

	override method cubre(consumo) = consumo.costo() <= self.remanente()

}

class MBsLibres inherits PackConsumible {

	override method cubre(consumo) = consumo.cubiertoPorInternet(self)

	method puedeGastarMB(cantidad1) = cantidad <= self.remanente()

}

class MBsLibresPlus inherits MBsLibres {

	override method puedeGastarMB(cantidad1) = super(cantidad) || cantidad < 0.1

}

class PackIlimitado inherits Pack {

	method consumir(consumo) {
	}

	override method acabado() = false

	method puedeGastarMB(cantidad) = true

	method puedeGastarMinutos(cantidad) = true

}

class LlamadasGratis inherits PackIlimitado {

	override method cubre(consumo) = consumo.cubiertoPorLlamadas(self)

}

class InternetLibreLosFindes inherits PackIlimitado {

	override method cubre(consumo) = consumo.cubiertoPorInternet(self) && consumo.fechaRealizado().internalDayOfWeek() > 5

}

//Vigencias
object ilimitado {

	method vencido() = false

}

class Vencimiento {

	const fecha

	method vencido() = fecha < new Date()

}