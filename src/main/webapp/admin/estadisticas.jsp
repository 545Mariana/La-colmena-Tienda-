<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ page import="java.util.*"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Estadísticas - Tienda Online</title>
<link rel="stylesheet" href="css/style.css">
<style>
.stats-container {
    max-width: 1400px;
    margin: 20px auto;
    padding: 20px;
}

.stats-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
}


.charts-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
    gap: 30px;
    margin-top: 20px;
}

.chart-container {
    background: black;
    border-radius: 10px;
    padding: 20px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
    border: 1px solid #e0e0e0;
    text-align: center;
}

.chart-title {
    margin-bottom: 20px;
    color: #ffffff;
    font-size: 1.2em;
    font-weight: bold;
}

.chart-image {
    max-width: 100%;
    height: 300px;
    border: 1px solid #ddd;
    border-radius: 5px;
    object-fit: contain;
}

.stats-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.stat-card {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 20px;
    border-radius: 10px;
    text-align: center;
}

.stat-card h3 {
    margin-top: 0;
    font-size: 0.9em;
    opacity: 0.9;
}

.stat-card .value {
    font-size: 2em;
    font-weight: bold;
    margin: 10px 0;
}

.chart-controls {
    margin-top: 10px;
    display: flex;
    justify-content: center;
    gap: 10px;
}

.chart-controls button {
    padding: 5px 10px;
    background-color: #f0f0f0;
    border: 1px solid #ddd;
    border-radius: 3px;
    cursor: pointer;
}

.chart-controls button:hover {
    background-color: #e0e0e0;
}

.no-data {
    text-align: center;
    padding: 50px;
    color: #666;
    font-style: italic;
}
</style>
</head>
<body>
    <div class="stats-container">
        <div class="stats-header">
            <h2>📊 Panel de Estadísticas</h2>
            <div>
                <button onclick="window.print()" class="btn-action">Imprimir</button>
            </div>
        </div>


        <!-- Tarjetas de resumen -->
        <div class="stats-cards">
            <sql:setDataSource var="conexion" dataSource="jdbc/TestDS" />

            <!-- Total Ventas -->
            <sql:query var="totalVentas" dataSource="${conexion}">
                SELECT COALESCE(SUM(dp.total_articulo), 0) as total
                FROM Pedido p
                JOIN DetallePedido dp ON p.id_pedido = dp.id_pedido
                WHERE 1=1
                <c:if test="${not empty param.anio}">
                    AND YEAR(p.fecha_pedido) = ?
                </c:if>
                <c:if test="${not empty param.trimestre}">
                    AND QUARTER(p.fecha_pedido) = ?
                </c:if>
            </sql:query>

            <!-- Total Pedidos -->
            <sql:query var="totalPedidos" dataSource="${conexion}">
                SELECT COUNT(*) as total
                FROM Pedido p
                WHERE 1=1
                <c:if test="${not empty param.anio}">
                    AND YEAR(p.fecha_pedido) = ?
                </c:if>
                <c:if test="${not empty param.trimestre}">
                    AND QUARTER(p.fecha_pedido) = ?
                </c:if>
            </sql:query>

            <!-- Clientes Activos -->
            <sql:query var="clientesActivos" dataSource="${conexion}">
                SELECT COUNT(DISTINCT p.id_cliente) as total
                FROM Pedido p
                WHERE 1=1
                <c:if test="${not empty param.anio}">
                    AND YEAR(p.fecha_pedido) = ?
                </c:if>
                <c:if test="${not empty param.trimestre}">
                    AND QUARTER(p.fecha_pedido) = ?
                </c:if>
            </sql:query>

            <!-- Ticket Promedio -->
            <sql:query var="ticketPromedio" dataSource="${conexion}">
                SELECT COALESCE(AVG(dp.total_articulo), 0) as promedio
                FROM Pedido p
                JOIN DetallePedido dp ON p.id_pedido = dp.id_pedido
                WHERE 1=1
                <c:if test="${not empty param.anio}">
                    AND YEAR(p.fecha_pedido) = ?
                </c:if>
                <c:if test="${not empty param.trimestre}">
                    AND QUARTER(p.fecha_pedido) = ?
                </c:if>
            </sql:query>

            <!-- Mostrar tarjetas -->
            <c:forEach var="venta" items="${totalVentas.rows}">
                <div class="stat-card"
                    style="background: linear-gradient(135deg, #4CAF50 0%, #2E7D32 100%);">
                    <h3>VENTAS TOTALES</h3>
                    <div class="value">
                        $
                        <fmt:formatNumber value="${venta.total}" type="number"
                            maxFractionDigits="2" />
                    </div>
                </div>
            </c:forEach>

            <c:forEach var="pedido" items="${totalPedidos.rows}">
                <div class="stat-card"
                    style="background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);">
                    <h3>TOTAL PEDIDOS</h3>
                    <div class="value">${pedido.total}</div>
                </div>
            </c:forEach>

            <c:forEach var="cliente" items="${clientesActivos.rows}">
                <div class="stat-card"
                    style="background: linear-gradient(135deg, #FF9800 0%, #F57C00 100%);">
                    <h3>CLIENTES ACTIVOS</h3>
                    <div class="value">${cliente.total}</div>
                </div>
            </c:forEach>

            <c:forEach var="ticket" items="${ticketPromedio.rows}">
                <div class="stat-card"
                    style="background: linear-gradient(135deg, #9C27B0 0%, #7B1FA2 100%);">
                    <h3>TICKET PROMEDIO</h3>
                    <div class="value">
                        $
                        <fmt:formatNumber value="${ticket.promedio}" type="number"
                            maxFractionDigits="2" />
                    </div>
                </div>
            </c:forEach>
        </div>

        <!-- Grid de Gráficas -->
        <div class="charts-grid">

            <!-- Gráfica 1: Ventas por Trimestre -->
            <div class="chart-container">
                <div class="chart-title">📈 Ventas por Trimestre</div>
                <c:choose>
                    <c:when test="${not empty param.anio or not empty param.trimestre}">
                        <img
                            src="../Estadisticas?tipo=ventasTrimestre&anio=${param.anio}&trimestre=${param.trimestre}"
                            alt="Ventas por Trimestre" class="chart-image">
                    </c:when>
                    <c:otherwise>
                        <img src="../Estadisticas?tipo=ventasTrimestre"
                            alt="Ventas por Trimestre" class="chart-image">
                    </c:otherwise>
                </c:choose>
                <div class="chart-controls">
                    <button onclick="actualizarGrafica(this, 'ventasTrimestre')">Actualizar</button>
                </div>
            </div>

            <!-- Gráfica 2: Pedidos por Estado -->
            <div class="chart-container">
                <div class="chart-title">📊 Estado de los Pedidos</div>
                <c:choose>
                    <c:when test="${not empty param.anio or not empty param.trimestre}">
                        <img
                            src="../Estadisticas?tipo=pedidosEstado&anio=${param.anio}&trimestre=${param.trimestre}"
                            alt="Estado de los Pedidos" class="chart-image">
                    </c:when>
                    <c:otherwise>
                        <img src="../Estadisticas?tipo=pedidosEstado"
                            alt="Estado de los Pedidos" class="chart-image">
                    </c:otherwise>
                </c:choose>
                <div class="chart-controls">
                    <button onclick="actualizarGrafica(this, 'pedidosEstado')">Actualizar</button>
                </div>
            </div>

            <!-- Gráfica 3: Productos Más Vendidos -->
            <div class="chart-container">
                <div class="chart-title">🏆 Productos Más Vendidos</div>
                <c:choose>
                    <c:when test="${not empty param.anio or not empty param.trimestre}">
                        <img
                            src="../Estadisticas?tipo=productosVendidos&anio=${param.anio}&trimestre=${param.trimestre}"
                            alt="Productos Más Vendidos" class="chart-image">
                    </c:when>
                    <c:otherwise>
                        <img src="../Estadisticas?tipo=productosVendidos"
                            alt="Productos Más Vendidos" class="chart-image">
                    </c:otherwise>
                </c:choose>
                <div class="chart-controls">
                    <button onclick="actualizarGrafica(this, 'productosVendidos')">Actualizar</button>
                </div>
            </div>

            <!-- Gráfica 4: Tiempos de Entrega -->
            <div class="chart-container">
                <div class="chart-title">⏱️ Tiempos de Entrega Promedio</div>
                <c:choose>
                    <c:when test="${not empty param.anio}">
                        <img src="../Estadisticas?tipo=tiemposEntrega&anio=${param.anio}"
                            alt="Tiempos de Entrega" class="chart-image">
                    </c:when>
                    <c:otherwise>
                        <img src="../Estadisticas?tipo=tiemposEntrega"
                            alt="Tiempos de Entrega" class="chart-image">
                    </c:otherwise>
                </c:choose>
                <div class="chart-controls">
                    <button onclick="actualizarGrafica(this, 'tiemposEntrega')">Actualizar</button>
                </div>
            </div>

            <!-- Gráfica 5: Ventas Mensuales -->
            <div class="chart-container">
                <div class="chart-title">📅 Ventas Mensuales</div>
                <c:choose>
                    <c:when test="${not empty param.anio}">
                        <img src="../Estadisticas?tipo=ventasMensuales&anio=${param.anio}"
                            alt="Ventas Mensuales" class="chart-image">
                    </c:when>
                    <c:otherwise>
                        <%
                        Calendar cal = Calendar.getInstance();
                        String anioActual = String.valueOf(cal.get(Calendar.YEAR));
                        %>
                        <img
                            src="../Estadisticas?tipo=ventasMensuales&anio=<%=anioActual%>"
                            alt="Ventas Mensuales" class="chart-image">
                    </c:otherwise>
                </c:choose>
                <div class="chart-controls">
                    <button onclick="actualizarGrafica(this, 'ventasMensuales')">Actualizar</button>
                </div>
            </div>

            <!-- Gráfica 6: Métodos de Pago -->
            <div class="chart-container">
                <div class="chart-title">💳 Métodos de Pago Utilizados</div>
                <c:choose>
                    <c:when test="${not empty param.anio}">
                        <img src="../Estadisticas?tipo=metodosPago&anio=${param.anio}"
                            alt="Métodos de Pago" class="chart-image">
                    </c:when>
                    <c:otherwise>
                        <img src="../Estadisticas?tipo=metodosPago" alt="Métodos de Pago"
                            class="chart-image">
                    </c:otherwise>
                </c:choose>
                <div class="chart-controls">
                    <button onclick="actualizarGrafica(this, 'metodosPago')">Actualizar</button>
                </div>
            </div>

        </div>

        <!-- Tabla de datos (ONLY_FULL_GROUP_BY) -->
        <div class="chart-container"
            style="margin-top: 30px; text-align: left;">
            <div class="chart-title">📋 Datos Detallados</div>
            <sql:query var="datosDetallados" dataSource="${conexion}">
                SELECT 
                    YEAR(p.fecha_pedido) as anio,
                    QUARTER(p.fecha_pedido) as trimestre,
                    COALESCE(SUM(dp.total_articulo), 0) as ventas_totales,
                    COUNT(DISTINCT p.id_pedido) as total_pedidos,
                    COUNT(DISTINCT p.id_cliente) as clientes_unicos,
                    COALESCE(AVG(dp.total_articulo), 0) as ticket_promedio
                FROM Pedido p
                LEFT JOIN DetallePedido dp ON p.id_pedido = dp.id_pedido
                WHERE 1=1
                <c:if test="${not empty param.anio}">
                    AND YEAR(p.fecha_pedido) = ?
                </c:if>
                <c:if test="${not empty param.trimestre}">
                    AND QUARTER(p.fecha_pedido) = ?
                </c:if>
                GROUP BY YEAR(p.fecha_pedido), QUARTER(p.fecha_pedido)
                ORDER BY YEAR(p.fecha_pedido) DESC, QUARTER(p.fecha_pedido) DESC
                LIMIT 8
                <c:if test="${not empty param.anio}">
                    <sql:param value="${param.anio}" />
                </c:if>
                <c:if test="${not empty param.trimestre}">
                    <sql:param value="${param.trimestre}" />
                </c:if>
            </sql:query>

            <c:choose>
                <c:when test="${datosDetallados.rowCount > 0}">
                    <table border="1" cellpadding="8"
                        style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr>
                                <th>Período</th>
                                <th>Ventas Totales</th>
                                <th>Pedidos</th>
                                <th>Clientes Únicos</th>
                                <th>Ticket Promedio</th>
                                <th>Producto Top</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="dato" items="${datosDetallados.rows}">
                                <tr>
                                    <td align="center">${dato.anio}-Q${dato.trimestre}</td>
                                    <td align="right">$<fmt:formatNumber
                                            value="${dato.ventas_totales}" type="number"
                                            maxFractionDigits="2" /></td>
                                    <td align="center">${dato.total_pedidos}</td>
                                    <td align="center">${dato.clientes_unicos}</td>
                                    <td align="right">$<fmt:formatNumber
                                            value="${dato.ticket_promedio}" type="number"
                                            maxFractionDigits="2" /></td>
                                    <td align="center"><sql:query var="productoTop"
                                            dataSource="${conexion}">
                                            SELECT pr.nombre_producto
                                            FROM DetallePedido dp
                                            JOIN Producto pr ON dp.id_producto = pr.id_producto
                                            JOIN Pedido p2 ON dp.id_pedido = p2.id_pedido
                                            WHERE YEAR(p2.fecha_pedido) = ?
                                              AND QUARTER(p2.fecha_pedido) = ?
                                            GROUP BY pr.id_producto
                                            ORDER BY SUM(dp.cantidad) DESC
                                            LIMIT 1
                                            <sql:param
                                                value="${dato.anio}" />
                                            <sql:param value="${dato.trimestre}" />
                                        </sql:query> <c:forEach var="prod" items="${productoTop.rows}">
                                            ${prod.nombre_producto}
                                        </c:forEach> <c:if
                                            test="${productoTop.rowCount == 0}">-</c:if></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:otherwise>
                    <div class="no-data">No hay datos para mostrar con los
                        filtros seleccionados</div>
                </c:otherwise>
            </c:choose>
        </div>

    </div>

    <script>
        // Función para actualizar una gráfica específica
        function actualizarGrafica(button, tipo) {
            var img = button.closest('.chart-container').querySelector('img');
            var timestamp = new Date().getTime();

            // Obtener parámetros actuales de la URL de la imagen
            var currentSrc = img.src;
            var urlParams = new URL(currentSrc).searchParams;
            var anio = urlParams.get('anio') || '';
            var trimestre = urlParams.get('trimestre') || '';

            // Construir nueva URL con timestamp para evitar caché
            var url = '../Estadisticas?tipo=' + tipo + '&_=' + timestamp;
            if (anio)
                url += '&anio=' + anio;
            if (trimestre)
                url += '&trimestre=' + trimestre;

            img.src = url;

            // Mostrar mensaje temporal
            var originalText = button.textContent;
            button.textContent = 'Actualizando...';
            button.disabled = true;

            setTimeout(function() {
                button.textContent = originalText;
                button.disabled = false;
            }, 1000);
        }

        // Auto-actualizar gráficas cada 5 minutos
        setInterval(function() {
            var timestamp = new Date().getTime();
            document.querySelectorAll('.chart-container img').forEach(
                    function(img) {
                        var src = img.src;
                        if (src.includes('../Estadisticas')) {
                            // Mantener parámetros existentes, solo actualizar timestamp
                            var url = new URL(src);
                            url.searchParams.set('_', timestamp);
                            img.src = url.toString();
                        }
                    });
        }, 300000); // 5 minutos
    </script>
</body>
</html>