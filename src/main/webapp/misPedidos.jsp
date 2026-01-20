<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Mis Pedidos - Colmena</title>
<meta name="decorator" content="main"/>
<style>
    .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
    }
    
    .resumen-cliente {
        background: linear-gradient(135deg, #000000 10%, #B8860B 100%);
        color: white;
        border-radius: 10px;
        padding: 25px;
        margin-bottom: 30px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    
    .resumen-item {
        text-align: center;
        padding: 10px;
    }
    
    .resumen-valor {
        font-size: 2.2rem;
        font-weight: bold;
        margin-bottom: 5px;
    }
    
    .resumen-label {
        font-size: 0.9rem;
        opacity: 0.9;
    }
    
    .pedido-card {
        border: 1px solid #e0e0e0;
        border-radius: 10px;
        margin-bottom: 20px;
        padding: 20px;
        background-color: #fff;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        transition: transform 0.2s, box-shadow 0.2s;
    }
    
    .pedido-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }
    
    .pedido-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
        padding-bottom: 15px;
        border-bottom: 2px solid #f8f9fa;
    }
    
    .estado-pedido {
        padding: 6px 15px;
        border-radius: 20px;
        font-weight: bold;
        font-size: 14px;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    
    .estado-entregado {
        background-color: #d4edda;
        color: #155724;
    }
    
    .estado-en-camino {
        background-color: #fff3cd;
        color: #856404;
    }
    
    .estado-en-proceso {
        background-color: #cce5ff;
        color: #004085;
    }
    
    .producto-item {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 12px 0;
        border-bottom: 1px solid #eee;
    }
    
    .producto-info h6 {
        margin: 0;
        color: #333;
    }
    
    .producto-cantidad {
        color: #666;
        font-size: 14px;
    }
    
    .producto-precio {
        font-weight: 600;
        color: #2c3e50;
    }
    
    .total-pedido {
        font-size: 18px;
        font-weight: bold;
        color: #e74c3c;
        text-align: right;
        margin-top: 15px;
        padding-top: 15px;
        border-top: 2px solid #f8f9fa;
    }
    
    .btn-detalle {
        background-color: #3498db;
        color: white;
        border: none;
        padding: 8px 16px;
        border-radius: 5px;
        cursor: pointer;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 5px;
        transition: background-color 0.3s;
    }
    
    .btn-detalle:hover {
        background-color: #2980b9;
        color: white;
        text-decoration: none;
    }
    
    .no-pedidos {
        text-align: center;
        padding: 60px 20px;
        color: #7f8c8d;
    }
    
    .no-pedidos i {
        font-size: 64px;
        margin-bottom: 20px;
        color: #f1c40f;
    }
    
    .no-pedidos h3 {
        margin-bottom: 10px;
        color: #34495e;
    }
    
    .btn-comprar {
        background-color: #2ecc71;
        color: white;
        border: none;
        padding: 12px 24px;
        border-radius: 5px;
        font-size: 16px;
        cursor: pointer;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        margin-top: 20px;
        transition: background-color 0.3s;
    }
    
    .btn-comprar:hover {
        background-color: #27ae60;
        color: white;
        text-decoration: none;
    }
    
    .timeline {
        display: flex;
        justify-content: space-between;
        margin: 20px 0;
        position: relative;
    }
    
    .timeline:before {
        content: '';
        position: absolute;
        top: 15px;
        left: 10%;
        right: 10%;
        height: 3px;
        background-color: #e0e0e0;
        z-index: 1;
    }
    
    .timeline-step {
        text-align: center;
        position: relative;
        z-index: 2;
        flex: 1;
    }
    
    .step-circle {
        width: 30px;
        height: 30px;
        border-radius: 50%;
        background-color: #e0e0e0;
        color: white;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 10px;
        font-weight: bold;
    }
    
    .step-circle.completed {
        background-color: #2ecc71;
    }
    
    .step-circle.active {
        background-color: #3498db;
    }
    
    .step-label {
        font-size: 12px;
        color: #7f8c8d;
    }
    
    .step-label.active {
        color: #3498db;
        font-weight: bold;
    }
    
    .step-label.completed {
        color: #2ecc71;
        font-weight: bold;
    }
</style>
</head>
<body>
<div class="container mt-4">
    <!-- Resumen del cliente -->
    <div class="resumen-cliente">
        <div class="row">
            <div class="col-md-4 resumen-item">
                <div class="resumen-valor">${totalPedidos}</div>
                <div class="resumen-label">Total Pedidos</div>
            </div>
            <div class="col-md-4 resumen-item">
                <div class="resumen-valor">
                    <fmt:formatNumber value="${totalGastado}" type="currency" currencySymbol="$" 
                                     maxFractionDigits="2" minFractionDigits="2"/>
                </div>
                <div class="resumen-label">Total Gastado</div>
            </div>
            <div class="col-md-4 resumen-item">
                <div class="resumen-valor">${pedidosEntregados}</div>
                <div class="resumen-label">Pedidos Entregados</div>
            </div>
        </div>
    </div>
    
    <h2 class="mb-4">Mis Pedidos</h2>
    
    <c:if test="${not empty param.success}">
        <div class="alert alert-success" style="padding: 15px; background-color: #d4edda; color: #155724; border-radius: 5px; margin-bottom: 20px;">
            <i class="fas fa-check-circle"></i> ${param.success}
        </div>
    </c:if>
    
    <c:if test="${not empty param.error}">
        <div class="alert alert-danger" style="padding: 15px; background-color: #f8d7da; color: #721c24; border-radius: 5px; margin-bottom: 20px;">
            <i class="fas fa-exclamation-circle"></i> ${param.error}
        </div>
    </c:if>
    
    <c:choose>
        <c:when test="${empty pedidos}">
            <div class="no-pedidos">
                <i class="fas fa-shopping-basket fa-4x"></i>
                <h3>No tienes pedidos aún</h3>
                <p>Cuando realices tu primer pedido, aparecerá aquí.</p>
                <a href="${pageContext.request.contextPath}/catalogo.jsp" class="btn-comprar">
                    <i class="fas fa-store"></i> Ver Productos
                </a>
            </div>
        </c:when>
        
        <c:otherwise>
            <c:forEach var="pedido" items="${pedidos}">
                <div class="pedido-card">
                    <div class="pedido-header">
                        <div>
                            <h5 class="mb-1">Pedido #PED-<fmt:formatNumber value="${pedido.idPedido}" pattern="000"/></h5>
                            <p class="text-muted mb-0">
                                <i class="far fa-calendar"></i> Fecha: ${pedido.fechaPedido}
                            </p>
                        </div>
                        <div>
                            <c:choose>
                                <c:when test="${pedido.estado == 'Entregado'}">
                                    <span class="estado-pedido estado-entregado">
                                        <i class="fas fa-check-circle"></i> Entregado
                                    </span>
                                </c:when>
                                <c:when test="${pedido.estado == 'En camino'}">
                                    <span class="estado-pedido estado-en-camino">
                                        <i class="fas fa-truck"></i> En camino
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="estado-pedido estado-en-proceso">
                                        <i class="fas fa-cog"></i> En proceso
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    
                    <!-- Timeline del pedido -->
                    <div class="timeline">
                        <div class="timeline-step">
                            <div class="step-circle 
                                <c:choose>
                                    <c:when test="${pedido.estado == 'Entregado' or pedido.estado == 'En camino' or pedido.estado == 'En proceso'}">completed</c:when>
                                    <c:otherwise></c:otherwise>
                                </c:choose>">
                                1
                            </div>
                            <div class="step-label 
                                <c:choose>
                                    <c:when test="${pedido.estado == 'Entregado' or pedido.estado == 'En camino' or pedido.estado == 'En proceso'}">completed</c:when>
                                    <c:otherwise></c:otherwise>
                                </c:choose>">
                                Confirmado
                            </div>
                        </div>
                        <div class="timeline-step">
                            <div class="step-circle 
                                <c:choose>
                                    <c:when test="${pedido.estado == 'Entregado' or pedido.estado == 'En camino'}">completed</c:when>
                                    <c:when test="${pedido.estado == 'En proceso'}">active</c:when>
                                    <c:otherwise></c:otherwise>
                                </c:choose>">
                                2
                            </div>
                            <div class="step-label 
                                <c:choose>
                                    <c:when test="${pedido.estado == 'Entregado' or pedido.estado == 'En camino'}">completed</c:when>
                                    <c:when test="${pedido.estado == 'En proceso'}">active</c:when>
                                    <c:otherwise></c:otherwise>
                                </c:choose>">
                                En Proceso
                            </div>
                        </div>
                        <div class="timeline-step">
                            <div class="step-circle 
                                <c:choose>
                                    <c:when test="${pedido.estado == 'Entregado'}">completed</c:when>
                                    <c:when test="${pedido.estado == 'En camino'}">active</c:when>
                                    <c:otherwise></c:otherwise>
                                </c:choose>">
                                3
                            </div>
                            <div class="step-label 
                                <c:choose>
                                    <c:when test="${pedido.estado == 'Entregado'}">completed</c:when>
                                    <c:when test="${pedido.estado == 'En camino'}">active</c:when>
                                    <c:otherwise></c:otherwise>
                                </c:choose>">
                                En Camino
                            </div>
                        </div>
                        <div class="timeline-step">
                            <div class="step-circle 
                                <c:choose>
                                    <c:when test="${pedido.estado == 'Entregado'}">completed</c:when>
                                    <c:otherwise></c:otherwise>
                                </c:choose>">
                                4
                            </div>
                            <div class="step-label 
                                <c:choose>
                                    <c:when test="${pedido.estado == 'Entregado'}">completed</c:when>
                                    <c:otherwise></c:otherwise>
                                </c:choose>">
                                Entregado
                            </div>
                        </div>
                    </div>
                    
                    <!-- Detalles del pedido -->
                    <div class="pedido-detalles">
                        <h6>Productos:</h6>
                        <c:forEach var="detalle" items="${pedido.detalles}">
                            <div class="producto-item">
                                <div class="producto-info">
                                    <h6>${detalle.nombreProducto}</h6>
                                    <div class="producto-cantidad">
                                        Cantidad: ${detalle.cantidad} × 
                                        <fmt:formatNumber value="${detalle.precioUnitario}" type="currency" 
                                                         currencySymbol="$" maxFractionDigits="2" minFractionDigits="2"/>
                                    </div>
                                </div>
                                <div class="producto-precio">
                                    <fmt:formatNumber value="${detalle.totalArticulo}" type="currency" 
                                                     currencySymbol="$" maxFractionDigits="2" minFractionDigits="2"/>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    
                    <div class="total-pedido">
                        Total del pedido: 
                        <fmt:formatNumber value="${pedido.total}" type="currency" 
                                         currencySymbol="$" maxFractionDigits="2" minFractionDigits="2"/>
                    </div>
                    
                    <div class="d-flex justify-content-between align-items-center mt-3">
                        <div>
                            <c:if test="${not empty pedido.fechaEnvio}">
                                <span class="text-muted">
                                    <i class="fas fa-shipping-fast"></i> Enviado: ${pedido.fechaEnvio}
                                </span>
                            </c:if>
                            <c:if test="${not empty pedido.fechaEntrega}">
                                <span class="text-success ml-3">
                                    <i class="fas fa-home"></i> Entregado: ${pedido.fechaEntrega}
                                </span>
                            </c:if>
                        </div>
                       
                    </div>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>

<script>
    
    
    // Agregar clases dinámicamente
    document.addEventListener('DOMContentLoaded', function() {
        // Actualizar timeline
        document.querySelectorAll('.pedido-card').forEach(card => {
            const estado = card.querySelector('.estado-pedido').textContent.trim();
            const circles = card.querySelectorAll('.step-circle');
            const labels = card.querySelectorAll('.step-label');
            
            if (estado === 'Entregado') {
                circles.forEach(circle => circle.classList.add('completed'));
                labels.forEach(label => label.classList.add('completed'));
            } else if (estado === 'En camino') {
                circles[0].classList.add('completed');
                circles[1].classList.add('completed');
                circles[2].classList.add('active');
                
                labels[0].classList.add('completed');
                labels[1].classList.add('completed');
                labels[2].classList.add('active');
            } else if (estado === 'En proceso') {
                circles[0].classList.add('completed');
                circles[1].classList.add('active');
                
                labels[0].classList.add('completed');
                labels[1].classList.add('active');
            }
        });
    });
</script>
</body>
</html>