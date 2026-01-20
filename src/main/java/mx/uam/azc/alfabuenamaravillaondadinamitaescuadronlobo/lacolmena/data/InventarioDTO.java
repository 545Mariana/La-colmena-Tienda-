package mx.uam.azc.alfabuenamaravillaondadinamitaescuadronlobo.lacolmena.data;

import java.io.Serializable;

public class InventarioDTO implements Serializable {
	private int _idInventario;
    private int _cantidad;
    
    // Constructores
    public InventarioDTO() {}
    
    public InventarioDTO(int cantidad) {
        this._cantidad = cantidad;
    }
    
    // Getters y Setters
    public int getIdInventario() { return this._idInventario; }
    public void setIdInventario(int idInventario) { this._idInventario = idInventario; }
    
    public int getCantidad() { return this._cantidad; }
    public void setCantidad(int cantidad) { 
        if (cantidad < 0) {
            throw new IllegalArgumentException("La cantidad no puede ser negativa");
        }
        this._cantidad = cantidad; 
    }
    
    // Métodos de negocio
    public boolean tieneStock() {
        return _cantidad > 0;
    }
    
    public boolean tieneStockSuficiente(int cantidadRequerida) {
        return _cantidad >= cantidadRequerida;
    }
    
    public void reducirStock(int cantidad) {
        if (cantidad > _cantidad) {
            throw new IllegalStateException("Stock insuficiente");
        }
        this._cantidad -= cantidad;
    }
    
    public void aumentarStock(int cantidad) {
        this._cantidad += cantidad;
    }
    
    @Override
    public String toString() {
        return String.format("InventarioDTO[id=%d, cantidad=%d]", _idInventario, _cantidad);
    }
}
