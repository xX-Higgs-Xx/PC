const diasSemana = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado'];

document.getElementById('fecha').addEventListener('input', () => {
    const inputFecha = document.getElementById('fecha');
    const fechaSeleccionada = (inputFecha.valueAsDate);

    if (fechaSeleccionada) {
        const fecha = new Date(fechaSeleccionada);
        const primerDiaSemana = obtenerPrimerDiaSemana(fecha);
        actualizarDivs(primerDiaSemana);
    }
});

function obtenerPrimerDiaSemana(fecha) {
    const primerDia = fecha.getDate() - fecha.getDay() + 1;
    return new Date(fecha.getFullYear(), fecha.getMonth(), primerDia);
}

function actualizarDivs(primerDiaSemana) {
    const contenedorFechas = document.getElementById('contenedorFechas');
    let contador = 0;

    diasSemana.forEach((dia, index) => {
        const fecha = new Date(primerDiaSemana);
        fecha.setDate(primerDiaSemana.getDate() + index);
        const fechaTexto = fecha.toLocaleDateString();
        console.log(diasSemana);
        const divDia = document.getElementById(dia);
        divDia.textContent = `${fechaTexto}`;
        switch(contador){
            case 0:
                let algo = document.querySelectorAll('.lunes');
                for(let cont of algo){
                    cont.setAttribute('data-date',fechaTexto);
                }
                break;
            case 1:
                let algo1 = document.querySelectorAll('.martes');
                for(let cont of algo1){
                    cont.setAttribute('data-date',fechaTexto);
                }
                break;
            case 2:
                let algo2 = document.querySelectorAll('.miercoles');
                for(let cont of algo2){
                    cont.setAttribute('data-date',fechaTexto);
                }
                break;
            case 3:
                let algo3 = document.querySelectorAll('.jueves');
                for(let cont of algo3){
                    cont.setAttribute('data-date',fechaTexto);
                }
                break;
            case 4:
                let algo4 = document.querySelectorAll('.viernes');
                for(let cont of algo4){
                    cont.setAttribute('data-date',fechaTexto);
                }
                break;
            case 5:
                let algo5 = document.querySelectorAll('.sabado');
                for(let cont of algo5){
                    cont.setAttribute('data-date',fechaTexto);
                }
                break;
            }
            contador++;

    });
}

//------------------------------------------------------------------

const horaCuadros = document.querySelectorAll('.hora-cuadro');
const horaSeleccionadaInput = document.getElementById('horaSeleccionada');

const divdiaSemana = document.getElementsByClassName("diaSemana");
const diaSelec = divdiaSemana.textContent;

const fechaInput = document.getElementById("form2");

horaCuadros.forEach(cuadro => {
     cuadro.addEventListener('click', () => {
         const hora = cuadro.getAttribute('data-hora');
         const fecha = cuadro.getAttribute('data-date');
         
         const horaSeleccionada = `${fecha} ${hora}`;
         console.log(horaSeleccionada);

         if(horaSeleccionada && (cuadro.getAttribute('data-date') != null)) {
            const listaFechas = document.getElementById('form2');
            fechaInput.value = horaSeleccionada;

            horaCuadros.forEach(div => {
                div.classList.remove('seleccionado');
            });
            cuadro.classList.add('seleccionado');
         }

        });
});


