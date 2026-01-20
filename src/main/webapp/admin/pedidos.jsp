<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Administración de Pedidos - Colmena</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <div class="container">
        <h2>Administración de Pedidos</h2>
        
        <div class="instructions">
            Aquí puede gestionar todos los pedidos del sistema. Puede actualizar su estado y agregar fechas de envío/entrega.
        </div>
        
        
        <div class="filter-section">
            <form method="get" action="" class="filter-form">
                <table class="filter-table">
                    <tr>
                        <td><strong>Filtrar por:</strong></td>
                        <td>
                            <label>Estado:</label>
                            <select name="estado" onchange="this.form.submit()">
                                <option value="">Todos</option>
                                <option value="preparando" ${param.estado == 'preparando' ? 'selected' : ''}>Preparando</option>
                                <option value="transito" ${param.estado == 'transito' ? 'selected' : ''}>En Tránsito</option>
                                <option value="entregado" ${param.estado == 'entregado' ? 'selected' : ''}>Entregado</option>
                            </select>
                        </td>
                        <td>
                            <label>Cliente:</label>
                            <input type="text" name="cliente" value="${param.cliente}" placeholder="Nombre del cliente" size="15">
                        </td>
                        <td>
                            <label>Desde:</label>
                            <input type="date" name="fecha_desde" value="${param.fecha_desde}">
                        </td>
                        <td>
                            <label>Hasta:</label>
                            <input type="date" name="fecha_hasta" value="${param.fecha_hasta}">
                        </td>
                        <td>
                            <input type="submit" value="Filtrar" class="btn-filter">
                            <input type="button" value="Limpiar" onclick="window.location='pedidos.jsp'" class="btn-reset">
                        </td>
                    </tr>
                </table>
            </form>
        </div>
        
        <sql:setDataSource var="conexion" dataSource="jdbc/TestDS" />
        
        
        <sql:query var="pedidos" dataSource="${conexion}">
            SELECT 
                p.id_pedido,
                p.fecha_pedido,
                p.fecha_envio,
                p.fecha_entrega,
                c.nombre,
                c.apellido_paterno,
                c.apellido_materno,
                c.num_telefonico,
                COALESCE(SUM(dp.total_articulo), 0) as total,
                CASE 
                    WHEN p.fecha_entrega IS NOT NULL THEN 'entregado'
                    WHEN p.fecha_envio IS NOT NULL AND p.fecha_entrega IS NULL THEN 'transito'
                    ELSE 'preparando'
                END as estado
            FROM Pedido p 
            JOIN Cliente c ON p.id_cliente = c.id_cliente
            LEFT JOIN DetallePedido dp ON p.id_pedido = dp.id_pedido
            WHERE 1=1
            <c:if test="${not empty param.estado}">
                AND CASE 
                    WHEN p.fecha_entrega IS NOT NULL THEN 'entregado'
                    WHEN p.fecha_envio IS NOT NULL AND p.fecha_entrega IS NULL THEN 'transito'
                    ELSE 'preparando'
                END = ?
            </c:if>
            <c:if test="${not empty param.cliente}">
                AND (c.nombre LIKE CONCAT('%', ?, '%') 
                     OR c.apellido_paterno LIKE CONCAT('%', ?, '%')
                     OR c.apellido_materno LIKE CONCAT('%', ?, '%'))
            </c:if>
            <c:if test="${not empty param.fecha_desde}">
                AND p.fecha_pedido >= ?
            </c:if>
            <c:if test="${not empty param.fecha_hasta}">
                AND p.fecha_pedido <= ?
            </c:if>
            GROUP BY p.id_pedido, p.fecha_pedido, p.fecha_envio, p.fecha_entrega,
                     c.nombre, c.apellido_paterno, c.apellido_materno, c.num_telefonico
            ORDER BY 
                CASE 
                    WHEN p.fecha_entrega IS NOT NULL THEN 3
                    WHEN p.fecha_envio IS NOT NULL AND p.fecha_entrega IS NULL THEN 2
                    ELSE 1
                END,
                p.fecha_pedido DESC
            
          
            <c:if test="${not empty param.estado}">
                <sql:param value="${param.estado}" />
            </c:if>
            <c:if test="${not empty param.cliente}">
                <sql:param value="${param.cliente}" />
                <sql:param value="${param.cliente}" />
                <sql:param value="${param.cliente}" />
            </c:if>
            <c:if test="${not empty param.fecha_desde}">
                <sql:param value="${param.fecha_desde}" />
            </c:if>
            <c:if test="${not empty param.fecha_hasta}">
                <sql:param value="${param.fecha_hasta}" />
            </c:if>
        </sql:query>

        
        <table border="1" cellpadding="5" cellspacing="0" class="data-table">
            <thead>
                <tr class="table-header">
                    <th>ID Pedido</th>
                    <th>Cliente</th>
                    <th>Teléfono</th>
                    <th>Fecha Pedido</th>
                    <th>Fecha Envío</th>
                    <th>Fecha Entrega</th>
                    <th>Total</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${pedidos.rowCount > 0}">
                        <c:forEach var="pedido" items="${pedidos.rows}">
                            <tr>
                                <td align="center">PED-<fmt:formatNumber value="${pedido.id_pedido}" pattern="000"/></td>
                                <td>${pedido.nombre} ${pedido.apellido_paterno} ${pedido.apellido_materno}</td>
                                <td>${pedido.num_telefonico}</td>
                                <td align="center">
                                    <fmt:parseDate value="${pedido.fecha_pedido}" pattern="yyyy-MM-dd" var="fechaPedidoParsed"/>
                                    <fmt:formatDate value="${fechaPedidoParsed}" pattern="dd/MM/yyyy"/>
                                </td>
                                <td align="center">
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
                                <td align="center">
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
                                <td align="right">$<fmt:formatNumber value="${pedido.total}" type="number" 
                                                   maxFractionDigits="2" minFractionDigits="2"/></td>
                                <td align="center">
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
                                <td align="center" nowrap>
                                    <input type="button" value="Ver Detalles" 
                                           onclick="window.location='detalle_pedido.jsp?id=${pedido.id_pedido}'"
                                           class="btn-action">
                                    
                                    <c:choose>
                                        <c:when test="${pedido.estado == 'preparando'}">
                                            <input type="button" value="Marcar Envío" 
                                                   onclick="mostrarModalEnvio(${pedido.id_pedido})"
                                                   class="btn-action btn-primary">
                                        </c:when>
                                        <c:when test="${pedido.estado == 'transito'}">
                                            <input type="button" value="Marcar Entrega" 
                                                   onclick="mostrarModalEntrega(${pedido.id_pedido})"
                                                   class="btn-action btn-success">
                                        </c:when>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="9" align="center" class="no-data">
                                No se encontraron pedidos con los criterios seleccionados
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
        
       
        <div class="summary">
            <strong>Total de pedidos: ${pedidos.rowCount}</strong>
        </div>
    </div>
    
    
    <div id="modalEnvio" class="modal" style="display: none;">
        <div class="modal-content">
            <h3>Marcar como Enviado</h3>
            <form id="formEnvio" method="post" action="${pageContext.request.contextPath}/ActualizarPedidos">
                <input type="hidden" name="action" value="marcarEnviado">
                <input type="hidden" name="id_pedido" id="id_pedido_envio">
                
                <table>
                    <tr>
                        <td>Fecha de envío:</td>
                        <td><input type="date" name="fecha_envio" id="fecha_envio" required 
                                   value="<fmt:formatDate value='<%=new java.util.Date()%>' pattern='yyyy-MM-dd'/>"></td>
                    </tr>
                    <tr>
                        <td>Observaciones:</td>
                        <td><textarea name="observaciones" rows="3" cols="30"></textarea></td>
                    </tr>
                </table>
                
                <div class="modal-buttons">
                    <input type="submit" value="Confirmar Envío" class="btn-primary">
                    <input type="button" value="Cancelar" onclick="cerrarModal('modalEnvio')" class="btn-reset">
                </div>
            </form>
        </div>
    </div>
    
   
    <div id="modalEntrega" class="modal" style="display: none;">
        <div class="modal-content">
            <h3>Marcar como Entregado</h3>
            <form id="formEntrega" method="post" action="${pageContext.request.contextPath}/ActualizarPedidos">
                <input type="hidden" name="action" value="marcarEntregado">
                <input type="hidden" name="id_pedido" id="id_pedido_entrega">
                
                <table>
                    <tr>
                        <td>Fecha de entrega:</td>
                        <td><input type="date" name="fecha_entrega" id="fecha_entrega" required 
                                   value="<fmt:formatDate value='<%=new java.util.Date()%>' pattern='yyyy-MM-dd'/>"></td>
                    </tr>
                   
                </table>
                
                <div class="modal-buttons">
                    <input type="submit" value="Confirmar Entrega" class="btn-success">
                    <input type="button" value="Cancelar" onclick="cerrarModal('modalEntrega')" class="btn-reset">
                </div>
            </form>
        </div>
    </div>
    
    <script type="text/javascript">
        function mostrarModalEnvio(idPedido) {
            document.getElementById('id_pedido_envio').value = idPedido;
            document.getElementById('modalEnvio').style.display = 'block';
        }
        
        function mostrarModalEntrega(idPedido) {
            document.getElementById('id_pedido_entrega').value = idPedido;
            
            // Si hay fecha de envío, sugerir fecha de entrega (2 días después)
            var fechaEnvio = document.querySelector('tr td:nth-child(5)')?.textContent;
            if (fechaEnvio && fechaEnvio.trim() !== 'No asignada') {
                var fecha = new Date();
                fecha.setDate(fecha.getDate() + 2); // 2 días después
                var fechaFormateada = fecha.toISOString().split('T')[0];
                document.getElementById('fecha_entrega').value = fechaFormateada;
            }
            
            document.getElementById('modalEntrega').style.display = 'block';
        }
        
        function cerrarModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
        }
        
        // Cerrar modal al hacer clic fuera
        window.onclick = function(event) {
            if (event.target.className === 'modal') {
                event.target.style.display = 'none';
            }
        }
        
        // Mostrar mensaje si existe
        <c:if test="${not empty param.success}">
            alert('${param.success}');
        </c:if>
        
        <c:if test="${not empty param.error}">
            alert('Error: ${param.error}');
        </c:if>
    </script>
</body>
</html>