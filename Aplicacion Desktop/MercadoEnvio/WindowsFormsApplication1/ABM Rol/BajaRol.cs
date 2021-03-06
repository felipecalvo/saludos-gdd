﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WindowsFormsApplication1.Extras;

namespace WindowsFormsApplication1.ABM_Rol
{
    public partial class BajaRol : Form
    {
        public BajaRol()
        {
            InitializeComponent();
            ConfiguradorVentana.configurarVentana(this);
        }

        public void bajaRol(int idRol)
        {
            this.borrarRol(idRol);
        }

        public void borrarRol(int idRol)
        {
            SQLManager manager = new SQLManager().generarSP("borrarRol")
                     .agregarIntSP("@id_rol", idRol);

            manager.ejecutarSP();
        }
    }
}
