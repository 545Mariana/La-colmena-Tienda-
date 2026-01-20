<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>

<%
    // Verificar sesión
    HttpSession currentSession = request.getSession(false);
    if (currentSession == null || currentSession.getAttribute("id_cliente") == null) {
        response.sendRedirect("login.jsp?msg=Debe+iniciar+sesión+para+finalizar+compra");
        return;
    }
    
    // Obtener carrito
    java.util.Map<Integer, Integer> carrito = 
        (java.util.Map<Integer, Integer>) currentSession.getAttribute("carrito");
    if (carrito == null || carrito.isEmpty()) {
        response.sendRedirect("carrito.jsp?msg=El+carrito+está+vacío");
        return;
    }
    
    // Guardar id_cliente para usar en la página
    Integer idCliente = (Integer) currentSession.getAttribute("id_cliente");
    pageContext.setAttribute("idCliente", idCliente);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Finalizar Compra - Tienda Online</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .checkout-container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
        }
        .checkout-section {
            border: 1px solid #ddd;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 5px;
           
        }
        .checkout-section h3 {
            margin-top: 0;        
            border-bottom: 2px solid #FFD700;
            padding-bottom: 10px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .form-row {
            display: flex;
            gap: 15px;
            margin-bottom: 15px;
        }
        .form-row .form-group {
            flex: 1;
        }
        .order-summary {
            
            padding: 15px;
            border-radius: 5px;
            border: 1px solid #ddd;
        }
        .order-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        .order-total {
            font-weight: bold;
            font-size: 1.2em;       
            margin-top: 10px;
            padding-top: 10px;
            border-top: 2px solid #ddd;
            color: FFD700;
            display: flex;
            justify-content: space-between;
        }
        .btn-checkout {
            width: 100%;
            padding: 12px;   
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 20px;
        }
        .btn-checkout:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <div class="checkout-container">
      
        <!-- Mostrar mensajes de error -->
        <c:if test="${not empty param.msg}">
            <div style="background-color: #ffebee; color: #c62828; padding: 10px; border-radius: 4px; margin-bottom: 20px;">
                <%= request.getParameter("msg").replace("+", " ") %>
            </div>
        </c:if>
        
        <sql:setDataSource var="conexion" dataSource="jdbc/TestDS" />
        
        <!-- Información del Cliente -->
        <sql:query var="clienteInfo" dataSource="${conexion}">
            SELECT 
                c.id_cliente,
                c.nombre,
                c.apellido_paterno,
                c.apellido_materno,
                c.domicilio,
                c.codigo_postal,
                c.num_telefonico,
                c.tarjeta_credito,
                c.fecha_expiracion,
                b.nombre_banco,
                b.id_banco
            FROM Cliente c
            LEFT JOIN Banco b ON c.id_banco = b.id_banco
            WHERE c.id_cliente = ?
            <sql:param value="${idCliente}" />
        </sql:query>
        
        <c:if test="${clienteInfo.rowCount > 0}">
            <c:set var="cliente" value="${clienteInfo.rows[0]}" />
            
            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 30px;">
                <!-- Columna Izquierda: Formulario -->
                <div>
                    <form method="post" action="${pageContext.request.contextPath}/checkout">
                        
                        <!-- Información de Envío -->
                        <div class="checkout-section">
                            <h3>Información de Envío</h3>
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="nombre">Nombre *</label>
                                    <input type="text" id="nombre" name="nombre" 
                                           value="${cliente.nombre}" required>
                                </div>
                                <div class="form-group">
                                    <label for="apellido_paterno">Apellido Paterno *</label>
                                    <input type="text" id="apellido_paterno" name="apellido_paterno" 
                                           value="${cliente.apellido_paterno}" required>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label for="domicilio">Dirección *</label>
                                <input type="text" id="domicilio" name="domicilio" 
                                       value="${cliente.domicilio}" required>
                            </div>
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="codigo_postal">Código Postal *</label>
                                    <input type="text" id="codigo_postal" name="codigo_postal" 
                                           value="${cliente.codigo_postal}" required>
                                </div>
                                <div class="form-group">
                                    <label for="telefono">Teléfono *</label>
                                    <input type="tel" id="telefono" name="telefono" 
                                           value="${cliente.num_telefonico}" required>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Información de Pago -->
                        <div class="checkout-section">
                            <h3>Información de Pago</h3>
                            
                            <div class="form-group">
                                <label for="tarjeta_credito">Número de Tarjeta *</label>
                                <input type="text" id="tarjeta_credito" name="tarjeta_credito" 
                                       placeholder="1234 5678 9012 3456"
                                       value="${cliente.tarjeta_credito}"
                                       required>
                            </div>
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="fecha_expiracion">Fecha de Expiración *</label>
                                    <input type="text" id="fecha_expiracion" name="fecha_expiracion" 
                                           placeholder="MM/AA" 
                                           value="${cliente.fecha_expiracion}"
                                           required>
                                </div>
                                <div class="form-group">
                                    <label for="cvv">CVV *</label>
                                    <input type="text" id="cvv" name="cvv" placeholder="123" required>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label for="id_banco">Banco</label>
                                <select id="id_banco" name="id_banco">
                                    <option value="">Seleccione un banco</option>
                                    <sql:query var="bancos" dataSource="${conexion}">
                                        SELECT id_banco, nombre_banco FROM Banco ORDER BY nombre_banco
                                    </sql:query>
                                    <c:forEach var="banco" items="${bancos.rows}">
                                        <option value="${banco.id_banco}" 
                                                ${banco.id_banco == cliente.id_banco ? 'selected' : ''}>
                                            ${banco.nombre_banco}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>
                        
                        <!-- Términos y condiciones -->
                        <div class="checkout-section">
                            <div class="form-group">
                                <label>
                                    <input type="checkbox" name="terminos" required>
                                    Acepto los términos y condiciones*
                                </label>
                            </div>
                            
                            <button type="submit" class="btn-checkout">
                                Confirmar Pedido
                            </button>
                        </div>
                        
                    </form>
                </div>
                
                <!-- Columna Derecha: Resumen del Pedido -->
                <div>
                    <div class="checkout-section">
                        <h3>Resumen del Pedido</h3>
                        
                        <div class="order-summary">
                            <!-- Calcular totales del carrito -->
                            <c:set var="carritoSession" value="${sessionScope.carrito}" />
                            <c:set var="subtotal" value="0" />
                            <c:set var="totalItems" value="0" />
                            
                            <c:forEach var="item" items="${carritoSession}">
                                <sql:query var="productoInfo" dataSource="${conexion}">
                                    SELECT id_producto, nombre_producto, precio_articulo 
                                    FROM Producto 
                                    WHERE id_producto = ?
                                    <sql:param value="${item.key}" />
                                </sql:query>
                                
                                <c:if test="${productoInfo.rowCount > 0}">
                                    <c:set var="producto" value="${productoInfo.rows[0]}" />
                                    <c:set var="precioItem" value="${producto.precio_articulo * item.value}" />
                                    <c:set var="subtotal" value="${subtotal + precioItem}" />
                                    <c:set var="totalItems" value="${totalItems + item.value}" />
                                    
                                    <div class="order-item">
                                        <div>
                                            ${producto.nombre_producto}<br>
                                            <small>Cantidad: ${item.value} x $<fmt:formatNumber value="${producto.precio_articulo}" 
                                                   type="number" maxFractionDigits="2"/></small>
                                        </div>
                                        <div>
                                            $<fmt:formatNumber value="${precioItem}" 
                                               type="number" maxFractionDigits="2"/>
                                        </div>
                                    </div>
                                </c:if>
                            </c:forEach>
                            
                            <div class="order-item">
                                <span>Subtotal (${totalItems} items):</span>
                                <span>$<fmt:formatNumber value="${subtotal}" 
                                       type="number" maxFractionDigits="2"/></span>
                            </div>
                            
                            <div class="order-item">
                                <span>Envío:</span>
                                <span>$<fmt:formatNumber value="50.00" 
                                       type="number" maxFractionDigits="2"/></span>
                            </div>
                            
                            <div class="order-item">
                                <span>IVA (16%):</span>
                                <span>$<fmt:formatNumber value="${subtotal * 0.16}" 
                                       type="number" maxFractionDigits="2"/></span>
                            </div>
                            
                            <div class="order-total">
                                <span>Total:</span>
                                <span>$<fmt:formatNumber value="${subtotal + 50.00 + (subtotal * 0.16)}" 
                                       type="number" maxFractionDigits="2"/></span>
                            </div>
                        </div>
                        
                        <div style="text-align: center; margin-top: 20px;">
                            <a href="carrito.jsp" class="btn-action">← Volver al Carrito</a>
                        </div>
                    </div>
                </div>
            </div>
        </c:if>
    </div>
    
    <script>
        // Formatear número de tarjeta
        document.getElementById('tarjeta_credito')?.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
            let formatted = value.match(/.{1,4}/g)?.join(' ') || '';
            e.target.value = formatted.substring(0, 19);
        });
        
        // Formatear fecha de expiración
        document.getElementById('fecha_expiracion')?.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
            if (value.length >= 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }
            e.target.value = value.substring(0, 5);
        });
        
        // Validar CVV
        document.getElementById('cvv')?.addEventListener('input', function(e) {
            e.target.value = e.target.value.replace(/[^0-9]/gi, '').substring(0, 3);
        });
    </script>
</body>
</html>
