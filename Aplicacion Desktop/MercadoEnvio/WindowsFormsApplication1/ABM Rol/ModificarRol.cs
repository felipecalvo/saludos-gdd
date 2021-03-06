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
    public partial class ModificarRol : Form
    {
        int idRol;
        String nombreRol;
        int habilitado;
        List<String> funcionalidadesViejas;
        List<String> funcionalidadesNuevas;
        List<String> funcionalidadesAEliminar;

        public ModificarRol()
        {
            InitializeComponent();
            ConfiguradorVentana.configurarVentana(this);
            funcionalidadesViejas = new List<String>();
            funcionalidadesNuevas = new List<String>();
            funcionalidadesAEliminar = new List<String>();
        }

        public void setIdRol(int idRol)
        {
            this.idRol = idRol;
        }

        public void setNombreRol(String nombreRol)
        {
            this.nombreRol = nombreRol;
            textBox1.Text = nombreRol;
        }

        public void setHabilitado(int habilitado)
        {
            this.habilitado = habilitado;

            if (habilitado.Equals(0))
                checkBox1.Checked = false;
            else
                checkBox1.Checked = true;
        }

        private int getHabilitado()
        {
            if (checkBox1.Checked)
                return 1;
            else
                return 0;
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        public void addFuncionalidad(String nombreFuncionalidad)
        {
            if(!listBox1.Items.Contains(nombreFuncionalidad))
                listBox1.Items.Add(nombreFuncionalidad);

            if (funcionalidadesAEliminar.Contains(nombreFuncionalidad))
                funcionalidadesAEliminar.Remove(nombreFuncionalidad);

            if (!funcionalidadesViejas.Contains(nombreFuncionalidad))
                funcionalidadesNuevas.Add(nombreFuncionalidad);
        }

        private void eliminarFuncionalidadSeleccionada()
        {
            if (listBox1.SelectedItems.Count > 0)
            {
                if (funcionalidadesViejas.Contains(listBox1.SelectedItem.ToString()))
                    funcionalidadesAEliminar.Add(listBox1.SelectedItem.ToString());

                if (funcionalidadesNuevas.Contains(listBox1.SelectedItem.ToString()))
                    funcionalidadesNuevas.Remove(listBox1.SelectedItem.ToString());

                listBox1.Items.Remove(listBox1.SelectedItem);
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            ABM_Rol.ListadoFuncionalidades listadoFuncionalidades = new ListadoFuncionalidades(this);
            listadoFuncionalidades.Show();
        }

        private void button4_Click(object sender, EventArgs e)
        {
            this.eliminarFuncionalidadSeleccionada();
        }

        private void limpiarCampos()
        {
            textBox1.Clear();
            listBox1.Items.Clear();
        }

        private void modificarRol()
        {
            String nombreRol = textBox1.Text;

            SQLManager manager = new SQLManager().generarSP("modificarRol")
                                 .agregarIntSP("@id_rol", idRol)
                                 .agregarStringSP("@nombre", nombreRol)
                                 .agregarIntSP("@habilitado", this.getHabilitado());

            manager.ejecutarSP();

            for(int i = 0; i<this.funcionalidadesNuevas.Count; i++)
            {
                manager = new SQLManager().generarSP("agregarFuncionalidadARol")
                    .agregarStringSP("@nombre_rol", nombreRol)
                    .agregarStringSP("@nombre_funcionalidad", this.funcionalidadesNuevas[i].ToString());

                    manager.ejecutarSP();
            }

            for (int i = 0; i < funcionalidadesAEliminar.Count; i++)
            {
                manager = new SQLManager().generarSP("quitarFuncionalidadDeRol")
                    .agregarStringSP("@nombre_rol", nombreRol)
                    .agregarStringSP("@nombre_funcionalidad", funcionalidadesAEliminar[i].ToString());

                manager.ejecutarSP();
            }
        }

        private void validarCampos()
        {
            this.validarNombre();
            this.validarFuncionalidades();
        }

        private void validarNombre()
        {
            if (Validacion.estaVacio(textBox1.Text))
                throw new Exception("Debe ingresar un nombre");

            if (!Validacion.empiezaConCaracter(textBox1.Text))
                throw new Exception("El nombre debe empezar con un caracter visible");

            if (!Validacion.contieneSoloLetrasOEspacios(textBox1.Text))
                throw new Exception("El nombre debe contener únicamente letras o espacios");
        }

        private void validarFuncionalidades()
        {
            if (listBox1.Items.Count.Equals(0))
                throw new Exception("El rol debe tener al menos una funcionalidad");
        }

        private void button1_Click(object sender, EventArgs e)
        {
            try
            {
                this.validarCampos();
                this.modificarRol();
                MessageBox.Show("Rol modificado exitosamente.");
                this.Close();
            }
            catch (Exception excepcion)
            {
                MessageBox.Show(excepcion.Message, "Error", MessageBoxButtons.OK);
            }
        }

        private void button2_Click(object sender, EventArgs e)
        {
            this.limpiarCampos();
        }

        public void setFuncionalidades()
        {
            List<String> funcionalidades = Dominio.Rol.getFuncionalidadesRol(nombreRol);

            for (int i = 0; i < funcionalidades.Count; i++)
            {
                listBox1.Items.Add(funcionalidades[i]);
            }
            
            funcionalidadesViejas.AddRange(funcionalidades);
        }
    }

}
