% cotizacion(Moneda, Hora, ValorEnPesos)
cotizacion(dolar, 8, 43).
cotizacion(lira, 8, 41).
cotizacion(dolar,9, 43.5).
cotizacion(lira, 9, 39).
cotizacion(dolar,10, 43.8).
cotizacion(lira, 10, 38).
cotizacion(patacon, 9, 200).
cotizacion(patacon, 10, 200).

% transaccion(Quien, Hora, Valor, Moneda)
transaccion(juanCarlos, 8, 100000, dolar).
transaccion(juanCarlos, 9, 1000, lira).
transaccion(ypf, 10, 100005349503495035930, dolar).

% cuenta(Quien, Balance, Banco)
cuenta(juanCarlos, 100, hete).
cuenta(juanCarlos, 2000, nejo).
cuenta(ypf, 10000000, nejo).

% persona(Quien, Trabajo)
%%% donde Trabajo puede ser:
%%%%% laburante(Trabajo, Provincia)
%%%%% juez
%%%%% empresa(CantidadDeEmpleados)
persona(juanCarlos, laburante(colectivero, rioNegro)).
persona(romina, laburante(docente,santaFe)).
persona(julian, juez).
persona(ypf, empresa(5000)).

salario(colectivero, 12000).

% Cuánto varió la cotizacion de una moneda a cierta hora del día, respecto de la hora anterior.
variacion(Moneda, Hora, Variacion) :-
  cotizacion(Moneda, Hora, Cotizacion),
  HoraAnterior is Hora - 1,
  cotizacion(Moneda, HoraAnterior, CotizacionAnterior),
  Variacion is Cotizacion - CotizacionAnterior.

% A cuanto cerró en el día la cotizacion de una moneda.
variacion(Moneda, Cotizacion) :-
  cotizacion(Moneda, UltimaHora, Cotizacion),
  not((cotizacion(Moneda, Hora, _), Hora > UltimaHora)).

% Quiénes hicieron transacciones com más de una moneda.
multiplesMonedas(Persona) :-
    transaccion(Persona, _, _, Moneda1),
    transaccion(Persona, _, _, Moneda2),
    Moneda1 \= Moneda2.

% La moneda de la que nadie hizo transacciones.
nadieLaUsa(Moneda) :-
  cotizacion(Moneda, _, _),
  not(transaccion(_, _, _, Moneda)).

% Quiénes hicieron alguna transacción por un valor de más de 1000000 de pesos
mueveMuchaPlata(Persona) :-
    transaccion(Persona, Hora, Cantidad, Moneda),
    convertirAPesos(Moneda, Cantidad, Hora, Pesos),
    Pesos > 1000000.

convertirAPesos(Moneda, Cantidad, Hora, Pesos) :-
  cotizacion(Moneda, Hora, PesosPorMoneda),
  Pesos is PesosPorMoneda * Cantidad.

% El total de pesos que a lo largo del día cambió una misma persona, ya sea en una o diferentes monedas.
transaccionEnPesos(Persona, Pesos) :-
  transaccion(Persona, Hora, Cantidad, Moneda),
  convertirAPesos(Moneda, Cantidad, Hora, Pesos).

totalEnPesos(Persona, Total) :-
  transaccion(Persona, _, _, _),
  findall(Pesos, transaccionEnPesos(Persona, Pesos), ListaDePesos),
  sumlist(ListaDePesos, Total).

% Al que hizo alguna transaccion por un importe superior a lo declarado en sus cuentas bancarias individualmente
quedoEnRojo(Persona) :-
  transaccionEnPesos(Persona, Pesos),
  cuenta(Persona, Tope, _),
  Pesos > Tope.

% A quien a lo largo del día hizo transacciones por un total mayor que el límite diario permitido de acuerdo a su situación laboral.
sePasoDelLimite(Persona) :-
  totalEnPesos(Persona, Total),
  not(bajoElLimite(Persona, Total)).

bajoElLimite(Persona, Plata):-
  persona(Persona, Cargo),
  bajoElLimitePorCargo(Cargo, Plata).

%%% Laburante: 10% de su salario, el cual es siempre igual para cada profesión, pero en caso de vivir en buenos aires, tiene 500 pesos más de límite.
%%% Empresa: 1000 veces la cantidad de empleados
%%% Juez: no tiene límites.
bajoElLimitePorCargo(juez, _).
bajoElLimitePorCargo(empresa(Laburantes), Plata) :- Plata < Laburantes * 1000.
bajoElLimitePorCargo(laburante(Laburo, Lugar), Plata) :-
  salario(Laburo, Salario),
  bonusPorLugar(Lugar, Bonus),
  (0.1 *Salario) + Bonus > Plata.
bonusPorLugar(buenosAires, 500).
bonusPorLugar(Lugar, 0) :- Lugar \= buenosAires.
