﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WindowsFormsApplication1.Extras;

namespace WindowsFormsApplication1.ABM_Rol
{
    public partial class ListadoFuncionalidades : Form
    {
        Form formAnterior;

        public ListadoFuncionalidades(Form formAnterior)
        {
            InitializeComponent();
            ConfiguradorVentana.configurarVentana(this);
            this.formAnterior = formAnterior;
            ConfiguradorDataGrid.configurar(dataGridView1);
            ConfiguradorDataGrid.llenarDataGridConConsulta(this.getFuncionalidades(), dataGridView1);
            dataGridView1.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
        }

        private SqlDataReader getFuncionalidades()
        {
            SqlDataReader reader;
            SqlCommand consulta = new SqlCommand();
            consulta.CommandType = CommandType.Text;
            consulta.CommandText = "SELECT FUNC_COD AS 'Código', FUNC_NOMBRE AS 'Nombre' from GD1C2016.SALUDOS.FUNCIONALIDADES";
            consulta.Connection = Program.conexionDB();
            reader = consulta.ExecuteReader();

            return reader;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            String nombreFuncionalidad;

            switch (formAnterior.Name)
            {
                case "AltaRol":
                    nombreFuncionalidad = dataGridView1.SelectedRows[0].Cells[1].Value.ToString();
                    (formAnterior as ABM_Rol.AltaRol).addFuncionalidad(nombreFuncionalidad);
                    break;

                case "ModificarRol":
                    nombreFuncionalidad = dataGridView1.SelectedRows[0].Cells[1].Value.ToString();
                    (formAnterior as ABM_Rol.ModificarRol).addFuncionalidad(nombreFuncionalidad);
                    break;
            }

            this.Close();
        }


    }
}
