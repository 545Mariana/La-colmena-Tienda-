<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>

<%
    // Verificar sesión
    HttpSession currentSession = request.getSession(false);
    if (currentSession == null || currentSession.getAttribute("id_cliente") == null) {
        response.sendRedirect("login.jsp?msg=Debe+iniciar+sesión");
        return;
    }
    
    String idPedido = request.getParameter("id");
    String total = request.getParameter("total");
    
    if (idPedido == null || total == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Confirmación de Pedido - Tienda Online</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .confirmation-container {
            border: 1px dashed #ccc;
            max-width: 800px;
            margin: 40px auto;
            padding: 40px;
            text-align: center;      
            border-radius: 10px;
           
        }
        .confirmation-icon {
            font-size: 80px;
            color: #4CAF50;
            margin-bottom: 20px;
        }
        .confirmation-number {
           
            padding: 15px;
            border-radius: 5px;
            font-size: 1.5em;
            margin: 20px 0;
            display: inline-block;
        }
        .order-details {
            text-align: left;       
            padding: 20px;
            border-radius: 8px;
            margin: 30px 0;
        }
        .next-steps {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
        }
        .step {
            display: flex;
            align-items: center;
            margin: 15px 0;
        }
        .step-number {          
            color: white;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 15px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="confirmation-container">
        <div class="confirmation-icon">✓</div>
        
        <h2>¡Pedido Confirmado!</h2>
        <p>Gracias por tu compra. Tu pedido ha sido procesado exitosamente.</p>
        
        <div class="confirmation-number">
            Número de Pedido: <strong>PED-<%= idPedido %></strong>
        </div>
        
        <div class="order-details">
            <h3>Detalles del Pedido</h3>
            <p><strong>Número de Pedido:</strong> PED-<%= idPedido %></p>
            <p><strong>Fecha:</strong> <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></p>
            <p><strong>Total:</strong> $<fmt:formatNumber value="<%= total %>" 
                       type="number" maxFractionDigits="2" minFractionDigits="2"/></p>
            <p><strong>Estado:</strong> <span style="color: #4CAF50; font-weight: bold;">Procesando</span></p>
            <p><strong>Método de Pago:</strong> Tarjeta de Crédito</p>
        </div>
        
        <p>Recibirás un correo de confirmación con los detalles de tu pedido.</p>
        
        <div class="next-steps">
            <h3>¿Qué sigue?</h3>
            
            <div class="step">
                <div class="step-number">1</div>
                <div>Procesaremos tu pedido en las próximas 24 horas</div>
            </div>
            
            <div class="step">
                <div class="step-number">2</div>
                <div>Te notificaremos cuando tu pedido sea enviado</div>
            </div>
            
            <div class="step">
                <div class="step-number">3</div>
                <div>El tiempo estimado de entrega es de 3-5 días hábiles</div>
            </div>
        </div>
        
        <div style="margin-top: 40px;">
            <a href="index.jsp" class="btn-action">Continuar Comprando</a>
            <a href="misPedidos.jsp" class="btn-action btn-primary" style="margin-left: 10px;">Ver Mis Pedidos</a>
        </div>
        
        <div style="margin-top: 20px; font-size: 0.9em; color: #666;">
            <p>¿Tienes preguntas? Contáctanos a <strong>ventas@colmena.com</strong></p>
        </div>
    </div>
</body>
</html></html>