package mx.uam.azc.alfabuenamaravillaondadinamitaescuadronlobo.lacolmena.data;

import java.io.Serializable;

public class ProductoDTO implements Serializable {
	private String _nombreProducto;
	private String _tipo;
	private String _precioArticulo;
	private String _idInventario;

	// Constructor vacío
	public ProductoDTO() {
	}

	// Constructor con parámetros
	public ProductoDTO(String nombreProducto, String tipo, String precioArticulo) {
		this._nombreProducto = nombreProducto;
		this._tipo = tipo;
		this._precioArticulo = precioArticulo;

	}

	public String getNombreProducto() {
		return this._nombreProducto;
	}

	public void setNombreProducto(String nombreProducto) {
		this._nombreProducto = nombreProducto;
	}

	public String getTipo() {
		return this._tipo;
	}

	public void setTipo(String tipo) {
		this._tipo = tipo;
	}

	public String getPrecioArticulo() {
		return this._precioArticulo;
	}

	public void setPrecioArticulo(String precioArticulo) {
		this._precioArticulo = precioArticulo;
	}

	public String getIdInventario() {
		return this._idInventario;
	}

	public void setIdInventario(String idInventario) {
		this._idInventario = idInventario;
	}

}
