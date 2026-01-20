package mx.uam.azc.alfabuenamaravillaondadinamitaescuadronlobo.lacolmena.data;

import java.io.Serializable;

public class editar_cuentaDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    private int _id_cliente;
    private String _nombre;
    private String _apellido_paterno;
    private String _apellido_materno;
    private String _contrasena;
    private String _domicilio;
    private String _codigo_postal;
    private String _num_telefonico;
    private String _tarjeta_credito;
    private String _fecha_expiracion;
    private int _id_banco;

    public editar_cuentaDTO() {
    }

    public int getId_cliente() {
        return this._id_cliente;
    }

    public void setId_cliente(int id_cliente) {
        this._id_cliente = id_cliente;
    }

    public String getNombre() {
        return this._nombre;
    }

    public void setNombre(String nombre) {
        this._nombre = nombre;
    }

    public String getApellido_paterno() {
        return this._apellido_paterno;
    }

    public void setApellido_paterno(String apellido_paterno) {
        this._apellido_paterno = apellido_paterno;
    }

    public String getApellido_materno() {
        return this._apellido_materno;
    }
    
    public void setApellido_materno(String apellido_materno) {
        this._apellido_materno = apellido_materno;
    }
    
    public String getContrasena() {
        return this._contrasena;
    }
    
    public void setContrasena(String contrasena) {
        this._contrasena = contrasena;
    }

    public String getDomicilio() {
        return this._domicilio;
    }

    public void setDomicilio(String domicilio) {
        this._domicilio = domicilio;
    }

    public String getCodigo_postal() {
        return this._codigo_postal;
    }

    public void setCodigo_postal(String codigo_postal) {
        this._codigo_postal = codigo_postal;
    }

    public String getNum_telefonico() {
        return this._num_telefonico;
    }

    public void setNum_telefonico(String num_telefonico) {
        this._num_telefonico = num_telefonico;
    }

    public String getTarjeta_credito() {
        return this._tarjeta_credito;
    }

    public void setTarjeta_credito(String tarjeta_credito) {
        this._tarjeta_credito = tarjeta_credito;
    }

    public String getFecha_expiracion() {
        return this._fecha_expiracion;
    }

    public void setFecha_expiracion(String fecha_expiracion) {
        this._fecha_expiracion = fecha_expiracion;
    }

    public int getId_banco() {
        return this._id_banco;
    }

    public void setId_banco(int id_banco) {
        this._id_banco = id_banco;
    }
}
