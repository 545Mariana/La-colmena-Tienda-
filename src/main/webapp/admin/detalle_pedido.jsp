<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>


<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Detalle del Pedido - Colmena</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%
        String idPedido = request.getParameter("id");
        if (idPedido == null || idPedido.trim().isEmpty()) {
            response.sendRedirect("pedidos.jsp");
            return;
        }
    %>
    
    <div class="container">
        <h2>Detalle del Pedido</h2>
        
        <div style="margin-bottom: 20px;">
            <input type="button" value="← Volver a Pedidos" 
                   onclick="window.location='pedidos.jsp'"
                   class="btn-action">
        </div>
        
        <sql:setDataSource var="conexion" dataSource="jdbc/TestDS" />
        
       
        <sql:query var="infoPedido" dataSource="${conexion}">
            SELECT 
                p.id_pedido,
                p.fecha_pedido,
                p.fecha_envio,
                p.fecha_entrega,
                CONCAT(c.nombre, ' ', c.apellido_paterno, ' ', c.apellido_materno) as cliente,
                c.domicilio,
                c.codigo_postal,
                c.num_telefonico,
                b.nombre_banco,
                c.tarjeta_credito,
                SUM(dp.total_articulo) as total_pedido,
                CASE 
                    WHEN p.fecha_entrega IS NOT NULL THEN 'entregado'
                    WHEN p.fecha_envio IS NOT NULL AND p.fecha_entrega IS NULL THEN 'transito'
                    ELSE 'preparando'
                END as estado
            FROM Pedido p
            JOIN Cliente c ON p.id_cliente = c.id_cliente
            LEFT JOIN Banco b ON c.id_banco = b.id_banco
            LEFT JOIN DetallePedido dp ON p.id_pedido = dp.id_pedido
            WHERE p.id_pedido = ?
            GROUP BY p.id_pedido, p.fecha_pedido, p.fecha_envio, p.fecha_entrega,
                     c.nombre, c.apellido_paterno, c.apellido_materno,
                     c.domicilio, c.codigo_postal, c.num_telefonico,
                     b.nombre_banco, c.tarjeta_credito
            <sql:param value="<%= idPedido %>"/>
        </sql:query>
        
        <c:if test="${infoPedido.rowCount > 0}">
            <c:set var="pedido" value="${infoPedido.rows[0]}" />
            
            
            <div class="info-section">
                <h3>Información del Pedido</h3>
                <table border="1" cellpadding="10" class="info-table">
                    <tr>
                        <th width="200">ID Pedido:</th>
                        <td>PED-<fmt:formatNumber value="${pedido.id_pedido}" pattern="000"/></td>
                    </tr>
                    <tr>
                        <th>Cliente:</th>
                        <td>${pedido.cliente}</td>
                    </tr>
                    <tr>
                        <th>Dirección:</th>
                        <td>${pedido.domicilio} (CP: ${pedido.codigo_postal})</td>
                    </tr>
                    <tr>
                        <th>Teléfono:</th>
                        <td>${pedido.num_telefonico}</td>
                    </tr>
                    <tr>
                        <th>Método de Pago:</th>
                        <td>${pedido.nombre_banco} - ****${fn:substring(pedido.tarjeta_credito, fn:length(pedido.tarjeta_credito)-4, fn:length(pedido.tarjeta_credito))}</td>
                    </tr>
                    <tr>
                        <th>Fecha Pedido:</th>
                        <td>
                            <fmt:parseDate value="${pedido.fecha_pedido}" pattern="yyyy-MM-dd" var="fechaPedidoParsed"/>
                            <fmt:formatDate value="${fechaPedidoParsed}" pattern="dd/MM/yyyy"/>
                        </td>
                    </tr>
                    <tr>
                        <th>Fecha Envío:</th>
                        <td>
                            <c:choose>
                                <c:when test="${not empty pedido.fecha_envio}">
                                    <fmt:parseDate value="${pedido.fecha_envio}" pattern="yyyy-MM-dd" var="fechaEnvioParsed"/>
                                    <fmt:formatDate value="${fechaEnvioParsed}" pattern="dd/MM/yyyy"/>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">No asignada</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                    <tr>
                        <th>Fecha Entrega:</th>
                        <td>
                            <c:choose>
                                <c:when test="${not empty pedido.fecha_entrega}">
                                    <fmt:parseDate value="${pedido.fecha_entrega}" pattern="yyyy-MM-dd" var="fechaEntregaParsed"/>
                                    <fmt:formatDate value="${fechaEntregaParsed}" pattern="dd/MM/yyyy"/>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-muted">Pendiente</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                    <tr>
                        <th>Estado:</th>
                        <td>
                            <c:choose>
                                <c:when test="${pedido.estado == 'preparando'}">
                                    <span class="status-badge status-preparing">Preparando</span>
                                </c:when>
                                <c:when test="${pedido.estado == 'transito'}">
                                    <span class="status-badge status-transit">En Tránsito</span>
                                </c:when>
                                <c:when test="${pedido.estado == 'entregado'}">
                                    <span class="status-badge status-delivered">Entregado</span>
                                </c:when>
                            </c:choose>
                        </td>
                    </tr>
                    <tr>
                        <th>Total del Pedido:</th>
                        <td class="total-amount">
                            $<fmt:formatNumber value="${pedido.total_pedido}" type="number" 
                                               maxFractionDigits="2" minFractionDigits="2"/>
                        </td>
                    </tr>
                </table>
            </div>
            
            
            <div class="info-section">
                <h3>Productos del Pedido</h3>
                <sql:query var="detalleProductos" dataSource="${conexion}">
                    SELECT 
                        dp.id_detalle,
                        pr.nombre_producto,
                        pr.tipo,
                        pr.precio_articulo,
                        dp.cantidad,
                        dp.total_articulo
                    FROM DetallePedido dp
                    JOIN Producto pr ON dp.id_producto = pr.id_producto
                    WHERE dp.id_pedido = ?
                    ORDER BY dp.id_detalle
                    <sql:param value="<%= idPedido %>"/>
                </sql:query>
                
                <table border="1" cellpadding="8" class="data-table">
                    <thead>
                        <tr class="table-header">
                            <th>Producto</th>
                            <th>Tipo</th>
                            <th>Precio Unitario</th>
                            <th>Cantidad</th>
                            <th>Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="producto" items="${detalleProductos.rows}">
                            <tr>
                                <td>${producto.nombre_producto}</td>
                                <td>${producto.tipo}</td>
                                <td align="right">$<fmt:formatNumber value="${producto.precio_articulo}" 
                                                   maxFractionDigits="2" minFractionDigits="2"/></td>
                                <td align="center">${producto.cantidad}</td>
                                <td align="right">$<fmt:formatNumber value="${producto.total_articulo}" 
                                                   maxFractionDigits="2" minFractionDigits="2"/></td>
                            </tr>
                        </c:forEach>
                        <tr class="total-row">
                            <td colspan="4" align="right"><strong>Total:</strong></td>
                            <td align="right" class="total-amount">
                                <strong>$<fmt:formatNumber value="${pedido.total_pedido}" 
                                           maxFractionDigits="2" minFractionDigits="2"/></strong>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            
        </c:if>
    </div>
</body>
</html>