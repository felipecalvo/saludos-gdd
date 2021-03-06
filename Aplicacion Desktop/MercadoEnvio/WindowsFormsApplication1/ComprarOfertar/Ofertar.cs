﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using WindowsFormsApplication1.Extras;

namespace WindowsFormsApplication1.ComprarOfertar
{
    public partial class Ofertar : Form
    {
        int codigoPublicacion;
        String username;

        public Ofertar(int codigoPublicacion, String username)
        {
            InitializeComponent();
            ConfiguradorVentana.configurarVentana(this);
            this.codigoPublicacion = codigoPublicacion;
            this.username = username;
            this.inicializarCampos();
        }

        private SqlDataReader detallesPublicacionSubasta()
        {
            SqlDataReader reader;
            SqlCommand consulta = new SqlCommand();
            consulta.CommandType = CommandType.Text;
            consulta.CommandText = "SELECT * from GD1C2016.SALUDOS.detallesPublicacionSubasta(@codigo)";
            consulta.Parameters.Add(new SqlParameter("@codigo", this.codigoPublicacion));
            consulta.Connection = Program.conexionDB();
            reader = consulta.ExecuteReader();
            reader.Read();

            return reader;
        }

        private void inicializarCampos()
        {
            SqlDataReader detallesPublicacionSubasta = this.detallesPublicacionSubasta();

            this.inicializarDescripcion(detallesPublicacionSubasta);
            this.inicializarRubro(detallesPublicacionSubasta);
            this.inicializarPermiteEnvio(detallesPublicacionSubasta);
            this.inicializarUltimaOferta(detallesPublicacionSubasta);
            this.inicializarPrecioSugerido(detallesPublicacionSubasta);
            this.inicializarBotonOfertar(detallesPublicacionSubasta);
        }

        private void inicializarBotonOfertar(SqlDataReader detallesPublicacionSubasta)
        {
            int cantidadCalificacionesPendientes = Dominio.Usuario.cantidadCalificacionesPendientes(this.username);
            String creadorPublicacion = detallesPublicacionSubasta.GetValue(5).ToString();
            String tipoUsuario = Dominio.Usuario.getTipoUsuario(this.username);

            if ((cantidadCalificacionesPendientes > 2))
            {
                button1.Enabled = false;
                label7.Show();
            }

            if (creadorPublicacion.Equals(this.username))
            {
                button1.Enabled = false;
                label3.Show();
            }

            if (tipoUsuario.Equals("Administrador"))
                button1.Enabled = false;
        }

        private void inicializarUltimaOferta(SqlDataReader detallesPublicacionSubasta)
        {
            textBox1.Text = detallesPublicacionSubasta.GetValue(3).ToString();
            numericUpDown1.Value = Convert.ToDecimal(textBox1.Text) + 1;
        }

        private void inicializarPrecioSugerido(SqlDataReader detallesPublicacionSubasta)
        {
            textBox3.Text = detallesPublicacionSubasta.GetValue(1).ToString();
        }

        private void inicializarDescripcion(SqlDataReader detallesPublicacionSubasta)
        {
            textBox2.Text = detallesPublicacionSubasta.GetValue(0).ToString();
        }

        private void inicializarRubro(SqlDataReader detallesPublicacionSubasta)
        {
            textBox5.Text = detallesPublicacionSubasta.GetValue(2).ToString();
        }

        private void inicializarPermiteEnvio(SqlDataReader detallesPublicacionSubasta)
        {
            int permiteEnvio = Convert.ToInt32(detallesPublicacionSubasta.GetValue(4));

            if (permiteEnvio.Equals(1))
                checkBox1.Show();
            else
            {
                checkBox1.Hide();
                checkBox1.Checked = false;
            }
        }


        private void textBox2_TextChanged(object sender, EventArgs e)
        {

        }

        private void button2_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private int optaPorEnvio()
        {
            if (checkBox1.Checked)
                return 1;
            else
                return 0;
        }

        private void validarOferta(int oferta)
        {
            SqlDataReader detallesPublicacionSubasta = this.detallesPublicacionSubasta();
            int ultimaOferta = Convert.ToInt32(detallesPublicacionSubasta.GetValue(3));

            if (oferta <= ultimaOferta)
                throw new Exception("El monto a ofertar debe ser mayor a la última oferta realizada");
        }

        private void ofertar()
        {
            int oferta = Convert.ToInt32(numericUpDown1.Value);

            try
            {
                this.validarOferta(oferta);

                SQLManager manager = new SQLManager().generarSP("ofertar")
                     .agregarIntSP("@codPublicacion", this.codigoPublicacion)
                     .agregarIntSP("@oferta", oferta)
                     .agregarStringSP("@usuario", this.username)
                     .agregarIntSP("@optaEnvio", this.optaPorEnvio());

                manager.ejecutarSP();

                textBox1.Text = oferta.ToString() + ",00";
                numericUpDown1.Value = (Convert.ToDecimal(textBox1.Text)) + 1;

                MessageBox.Show("Oferta realizada exitosamente.");
            }
            catch (Exception excepcion)
            {
                MessageBox.Show(excepcion.Message, "Error", MessageBoxButtons.OK);
            }

        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.ofertar();
        }
    }
}
