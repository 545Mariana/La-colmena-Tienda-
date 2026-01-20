<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Iniciar Sesión - Tienda Online</title>
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

                    <!--para hacer login en caso de que no este en sesion activa-->
                    <c:if test="${empty sessionScope.nombre}">
                        <form action="${pageContext.request.contextPath}/login" method="post">
                            <input type="hidden" name="action" value="login">

                            <table>
                                <tr>
                                    <td align="right">Usuario:</td>
                                    <td><input type="text"
                                        name="nombre" size="25" required></td>
                                </tr>
                                <tr>
                                    <td align="right">Contraseña:</td>
                                    <td><input type="password"
                                        name="contrasena" size="25" required></td>
                                </tr>
                            </table>

                            <br>

                            <input type="submit" value="  Ingresar  ">
                            <input type="button" value="  Registrarse  "
                                onclick="window.location='creacion_de_cuenta.jsp'">
                        </form>

                        <!-- verifica que la contraseña y usuario sean correctas-->
                        <c:if test="${param.msg == 'error'}">
                            <p align="center" style="color:red;"> nombre o contraseña incorrectos</p>
                        </c:if>
                    </c:if>

                    <!--  verifica si hay sesion -->
                    <c:if test="${not empty sessionScope.nombre}">
                        <div class="instructions">
                            Sesión iniciada como: <b>${sessionScope.nombre}</b>
                        </div>
                        <br>

                        <form action="${pageContext.request.contextPath}/login" method="post">
                            <input type="hidden" name="action" value="logout">
                            <input type="submit" value="Cerrar Sesión">
                            <input type="button" value="Editar informacion" onclick="window.location='editar_cuenta.jsp'">
                        </form>
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
