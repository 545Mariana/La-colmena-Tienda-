<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
     <meta charset="UTF-8">
    <meta name="Author" content="Alfa buena maravilla onda dinamita escuadrón lobo">
    <title>Carrito de Compras - Tienda Online</title>
    <link rel="stylesheet" href="css/style.css">
  </head>
  <body>
    <table border="0" cellpadding="0" cellspacing="0" width="800">
      <tbody>
        <tr>
          <td colspan="3" align="center" height="20">
            <!-- [[HEADER]] -->
          </td>
        </tr>
        <tr>
          <td class="menu" align="center" valign="top" width="150">
            <!--[[MENU]] -->
          </td>
          <td align="center" valign="top" width="625">

            <br>

            <!-- solo se agrega al carro teniendo sesion activa  -->
            <c:if test="${empty sessionScope.id_cliente}">
              <p style="color:red;" align="center">Debes iniciar sesion o registrate</p>
              <p align="center">
                <input value="Ir a Login" type="button" onclick="window.location='login.jsp'">
              </p>
            </c:if>

            <!-- se verifica la sesion del cliente -->
            <c:if test="${not empty sessionScope.id_cliente}">

              <!-- muestra el estado del carro actual -->
              <c:if test="${empty requestScope.items}">
                <p align="center">Tu carrito está vacío.</p>
              </c:if>

              <!-- el carrito muestra lo que se vaya agregando -->
              <c:if test="${not empty requestScope.items}">
                <table width="100%">
                  <tbody>
                    <tr class="form">
                      <td align="center"><div class="label"> Producto </div></td>
                      <td align="center"><div class="label"> Precio Unitario </div></td>
                      <td align="center"><div class="label"> Cantidad </div></td>
                      <td align="center"><div class="label"> Subtotal </div></td>
                      <td><br></td>
                    </tr>

                    <c:forEach var="it" items="${items}">
                      <tr>
                        <td align="center"> ${it.nombre} </td>
                        <td align="center"> $${it.precio} </td>

                        <td align="center">
                          <!-- Update cantidad -->
                          <form action="${pageContext.request.contextPath}/carrito" method="post" style="margin:0;">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id_producto" value="${it.id_producto}">
                            <select name="cantidad" onchange="this.form.submit()">
                              <c:forEach var="n" begin="1" end="10">
                                <option value="${n}" ${n == it.cantidad ? "selected" : ""}>${n}</option>
                              </c:forEach>
                            </select>
                          </form>
                        </td>

                        <td align="center"> $${it.subtotal} </td>

                        <td valign="bottom">
                          <!-- se agrega eliminar por si es el caso  -->
                          <form action="${pageContext.request.contextPath}/carrito" method="post" style="margin:0;">
                            <input type="hidden" name="action" value="remove">
                            <input type="hidden" name="id_producto" value="${it.id_producto}">
                            <input value="eliminar" type="submit">
                          </form>
                        </td>
                      </tr>
                    </c:forEach>

                    <tr>
                      <td colspan="3" align="right"> Total: </td>
                      <td align="center"> $${total} </td>
                      <td><br></td>
                    </tr>

                  </tbody>
                </table>

                <br>
                <!-- botones para o agregar o pagar  -->
                <input value="Seguir Comprando" onclick="window.location='catalogo.jsp'" type="button">
                <input value="Proceder al Pago" onclick="window.location='checkout.jsp'" type="button">

                <form action="${pageContext.request.contextPath}/carrito" method="post" style="margin-top:10px;">
                  <input type="hidden" name="action" value="clear">
                  <input value="Vaciar Carrito" type="submit">
                </form>
              </c:if>
            </c:if>
          </td>
        </tr>
        <tr>
          <td colspan="3" align="center">
            <!--[[FOOTER]] -->
          </td>
        </tr>
      </tbody>
    </table>
  </body>
</html>
