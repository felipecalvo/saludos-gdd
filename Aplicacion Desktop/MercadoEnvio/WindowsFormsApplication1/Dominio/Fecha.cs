﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WindowsFormsApplication1.Dominio
{
    class Fecha
    {
        //TODO: Codificar este metodo
        public static DateTime getFechaActual()
        {
            DateTime fechaActual = new DateTime();

            return fechaActual;
        }

        //Dado un string con el formato "Mes1-Mes2-Mes3" del trimestre, devuelve su nro. de trimestre
        public static int getNroTrimestreDesdeString(String trimestre)
        {

            int nroTrimestre;

            switch (trimestre)
            {
                case "Ene-Feb-Mar":
                    nroTrimestre = 1;
                    break;

                case "Abr-May-Jun":
                    nroTrimestre = 2;
                    break;

                case "Jul-Ago-Sep":
                    nroTrimestre = 3;
                    break;

                case "Oct-Nov-Dic":
                    nroTrimestre = 4;
                    break;

                default:
                    throw new Exception("El nombre del trimestre es invalido");
            }

            return nroTrimestre;
        }

        public static int getNroTrimestreDesdeDatetime(DateTime fecha)
        {
            if ((fecha.Month >= 1) && (fecha.Month <= 3))
                return 1;
            else
            {

                if ((fecha.Month >= 4) && (fecha.Month <= 6))
                    return 2;
                else
                {
                    if ((fecha.Month >= 7) && (fecha.Month <= 9))
                        return 3;

                    else return 4;
                }
            }

        }
    }
}
