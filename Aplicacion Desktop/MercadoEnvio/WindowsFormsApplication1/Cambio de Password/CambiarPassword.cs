﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WindowsFormsApplication1.Extras;

namespace WindowsFormsApplication1.Cambio_de_Password
{
    public partial class CambiarPassword : Form
    {
        String username;

        public CambiarPassword(String modo)
        {
            InitializeComponent();
            ConfiguradorVentana.configurarVentana(this);

            if (modo.Equals("Administrador"))
                textBox1.ReadOnly = true;
        }

        public void setUsername(String username)
        {
            this.username = username;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            try
            {
                this.validarPasswordNueva();
                this.cambiarPassword();
            }
            catch (Exception excepcion)
            {
                MessageBox.Show(excepcion.Message, "Error", MessageBoxButtons.OK);
                this.limpiarCampos();
            }

            this.Close();

        }

        private void validarPasswordNueva()
        {
            if (!textBox2.Text.Equals(textBox3.Text))
                throw new Exception("La password nueva no coincide");
        }

        private void limpiarCampos()
        {
            textBox1.Clear();
            textBox2.Clear();
            textBox3.Clear();
        }

        private void cambiarPassword()
        {
            SQLManager manager = new SQLManager().generarSP("cambiarPasswordAdmin")
                 .agregarStringSP("@username", username)
                 .agregarStringSP("@nuevaPassword", textBox2.Text);

            manager.ejecutarSP();
        }

    }
}
