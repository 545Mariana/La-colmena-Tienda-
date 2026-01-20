package mx.uam.azc.alfabuenamaravillaondaescuadronlobo.lacolmena.controller;

import java.awt.Color;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Calendar;

import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartUtils;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.renderer.category.BarRenderer;
import org.jfree.data.category.DefaultCategoryDataset;
import org.jfree.data.general.DefaultPieDataset;

public class EstadisticasServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private DataSource ds;
    
    @Override
    public void init() throws ServletException {
        try {
            InitialContext ctx = new InitialContext();
            ds = (DataSource) ctx.lookup("java:comp/env/jdbc/TestDS");
        } catch (Exception e) {
            throw new ServletException("Error al iniciar la conexión de la base de datos", e);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String tipo = request.getParameter("tipo");
        
        if (tipo == null) {
            // Redirigir a la página JSP principal
            request.getRequestDispatcher("admin/estadisticas.jsp").forward(request, response);
            return;
        }
        
        // Configurar respuesta para imagen
        response.setContentType("image/png");
        OutputStream out = response.getOutputStream();
        
        try (Connection con = ds.getConnection()) {
            JFreeChart chart = null;
            String anio = request.getParameter("anio");
            String trimestre = request.getParameter("trimestre");
            
            switch (tipo) {
                case "ventasTrimestre":
                    chart = crearGraficaVentasTrimestre(con, anio, trimestre);
                    break;
                    
                case "pedidosEstado":
                    chart = crearGraficaPedidosEstado(con, anio, trimestre);
                    break;
                    
                case "productosVendidos":
                    chart = crearGraficaProductosVendidos(con, anio, trimestre);
                    break;
                    
                case "tiemposEntrega":
                    chart = crearGraficaTiemposEntrega(con, anio);
                    break;
                    
                case "ventasMensuales":
                    chart = crearGraficaVentasMensuales(con, anio);
                    break;
                    
                case "metodosPago":
                    chart = crearGraficaMetodosPago(con, anio);
                    break;
                    
                default:
                    chart = crearGraficaDefault();
            }
            
            if (chart != null) {
                // Ajustar tamaño de la imagen
                ChartUtils.writeChartAsPNG(out, chart, 700, 400);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            // Crear gráfica de error
            JFreeChart errorChart = crearGraficaError("Error: " + e.getMessage());
            ChartUtils.writeChartAsPNG(out, errorChart, 700, 400);
        } finally {
            out.close();
        }
    }
    
    private JFreeChart crearGraficaVentasTrimestre(Connection con, String anio, String trimestre) throws Exception {
        DefaultCategoryDataset dataset = new DefaultCategoryDataset();
        
        String sql = "SELECT " +
                     "  QUARTER(p.fecha_pedido) as trimestre, " +
                     "  COALESCE(SUM(dp.total_articulo), 0) as total_ventas " +
                     "FROM Pedido p " +
                     "LEFT JOIN DetallePedido dp ON p.id_pedido = dp.id_pedido " +
                     "WHERE 1=1 ";
        
        if (anio != null && !anio.isEmpty()) {
            sql += " AND YEAR(p.fecha_pedido) = ? ";
        }
        
        sql += "GROUP BY QUARTER(p.fecha_pedido) " +
               "ORDER BY QUARTER(p.fecha_pedido)";
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            int paramIndex = 1;
            if (anio != null && !anio.isEmpty()) {
                ps.setInt(paramIndex++, Integer.parseInt(anio));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int trim = rs.getInt("trimestre");
                    double ventas = rs.getDouble("total_ventas");
                    dataset.addValue(ventas, "Ventas", "T" + trim);
                }
            }
        }
        
        JFreeChart chart = ChartFactory.createBarChart(
            "Ventas por Trimestre" + (anio != null ? " " + anio : ""),
            "Trimestre",
            "Ventas ($)",
            dataset,
            PlotOrientation.VERTICAL,
            true,
            true,
            false
        );
        
        chart.setBackgroundPaint(Color.WHITE);
        CategoryPlot plot = chart.getCategoryPlot();
        plot.setBackgroundPaint(new Color(240, 240, 240));
        
        BarRenderer renderer = (BarRenderer) plot.getRenderer();
        renderer.setSeriesPaint(0, new Color(79, 129, 189));
        
        return chart;
    }
    
    private JFreeChart crearGraficaPedidosEstado(Connection con, String anio, String trimestre) throws Exception {
        DefaultCategoryDataset dataset = new DefaultCategoryDataset();
        
        String sql = "SELECT " +
                     "  CASE " +
                     "    WHEN fecha_entrega IS NOT NULL THEN 'Entregado' " +
                     "    WHEN fecha_envio IS NOT NULL AND fecha_entrega IS NULL THEN 'En Tránsito' " +
                     "    ELSE 'Preparando' " +
                     "  END as estado, " +
                     "  COUNT(*) as cantidad " +
                     "FROM Pedido " +
                     "WHERE 1=1 ";
        
        if (anio != null && !anio.isEmpty()) {
            sql += " AND YEAR(fecha_pedido) = ? ";
        }
        if (trimestre != null && !trimestre.isEmpty()) {
            sql += " AND QUARTER(fecha_pedido) = ? ";
        }
        
        sql += "GROUP BY estado ORDER BY cantidad DESC";
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            int paramIndex = 1;
            if (anio != null && !anio.isEmpty()) {
                ps.setInt(paramIndex++, Integer.parseInt(anio));
            }
            if (trimestre != null && !trimestre.isEmpty()) {
                ps.setInt(paramIndex++, Integer.parseInt(trimestre));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String estado = rs.getString("estado");
                    int cantidad = rs.getInt("cantidad");
                    dataset.addValue(cantidad, "Pedidos", estado);
                }
            }
        }
        
        JFreeChart chart = ChartFactory.createBarChart(
            "Estado de los Pedidos",
            "Estado",
            "Cantidad de Pedidos",
            dataset,
            PlotOrientation.VERTICAL,
            true,
            true,
            false
        );
        
        chart.setBackgroundPaint(Color.WHITE);
        CategoryPlot plot = chart.getCategoryPlot();
        plot.setBackgroundPaint(new Color(240, 240, 240));
        
        return chart;
    }
    
    private JFreeChart crearGraficaProductosMasVendidos(Connection con, String anio, String trimestre) throws Exception {
        DefaultPieDataset dataset = new DefaultPieDataset();
        
        String sql = "SELECT " +
                     "  pr.nombre_producto, " +
                     "  SUM(dp.cantidad) as total_vendido " +
                     "FROM DetallePedido dp " +
                     "JOIN Producto pr ON dp.id_producto = pr.id_producto " +
                     "JOIN Pedido p ON dp.id_pedido = p.id_pedido " +
                     "WHERE 1=1 ";
        
        if (anio != null && !anio.isEmpty()) {
            sql += " AND YEAR(p.fecha_pedido) = ? ";
        }
        if (trimestre != null && !trimestre.isEmpty()) {
            sql += " AND QUARTER(p.fecha_pedido) = ? ";
        }
        
        sql += "GROUP BY pr.id_producto, pr.nombre_producto " +
               "ORDER BY total_vendido DESC " +
               "LIMIT 8";
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            int paramIndex = 1;
            if (anio != null && !anio.isEmpty()) {
                ps.setInt(paramIndex++, Integer.parseInt(anio));
            }
            if (trimestre != null && !trimestre.isEmpty()) {
                ps.setInt(paramIndex++, Integer.parseInt(trimestre));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String producto = rs.getString("nombre_producto");
                    int cantidad = rs.getInt("total_vendido");
                    if (producto != null && cantidad > 0) {
                        dataset.setValue(producto.length() > 15 ? producto.substring(0, 12) + "..." : producto, 
                                       cantidad);
                    }
                }
            }
        }
        
        if (dataset.getItemCount() == 0) {
            dataset.setValue("Sin datos", 1);
        }
        
        JFreeChart chart = ChartFactory.createPieChart(
            "Productos Más Vendidos",
            dataset,
            true,
            true,
            false
        );
        
        chart.setBackgroundPaint(Color.WHITE);
        return chart;
    }
    
    private JFreeChart crearGraficaTiemposEntrega(Connection con, String anio) throws Exception {
        DefaultCategoryDataset dataset = new DefaultCategoryDataset();
        
        String sql = "SELECT " +
                     "  QUARTER(fecha_pedido) as trimestre, " +
                     "  AVG(DATEDIFF(fecha_entrega, fecha_envio)) as dias_promedio " +
                     "FROM Pedido " +
                     "WHERE fecha_envio IS NOT NULL " +
                     "  AND fecha_entrega IS NOT NULL ";
        
        if (anio != null && !anio.isEmpty()) {
            sql += " AND YEAR(fecha_pedido) = ? ";
        }
        
        sql += "GROUP BY QUARTER(fecha_pedido) " +
               "ORDER BY trimestre";
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            if (anio != null && !anio.isEmpty()) {
                ps.setInt(1, Integer.parseInt(anio));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int trimestre = rs.getInt("trimestre");
                    double dias = rs.getDouble("dias_promedio");
                    if (!rs.wasNull()) {
                        dataset.addValue(dias, "Días", "T" + trimestre);
                    }
                }
            }
        }
        
        if (dataset.getRowCount() == 0) {
            dataset.addValue(0, "Días", "Sin datos");
        }
        
        JFreeChart chart = ChartFactory.createLineChart(
            "Tiempos de Entrega Promedio" + (anio != null ? " " + anio : ""),
            "Trimestre",
            "Días",
            dataset,
            PlotOrientation.VERTICAL,
            true,
            true,
            false
        );
        
        chart.setBackgroundPaint(Color.WHITE);
        CategoryPlot plot = chart.getCategoryPlot();
        plot.setBackgroundPaint(new Color(240, 240, 240));
        
        return chart;
    }
    
    private JFreeChart crearGraficaVentasMensuales(Connection con, String anioParam) throws Exception {
        DefaultCategoryDataset dataset = new DefaultCategoryDataset();
        
        String anio = anioParam;
        if (anio == null || anio.isEmpty()) {
            Calendar cal = Calendar.getInstance();
            anio = String.valueOf(cal.get(Calendar.YEAR));
        }
        
        String sql = "SELECT " +
                     "  MONTH(fecha_pedido) as mes, " +
                     "  COALESCE(SUM(total_articulo), 0) as ventas " +
                     "FROM ( " +
                     "  SELECT p.id_pedido, p.fecha_pedido, dp.total_articulo " +
                     "  FROM Pedido p " +
                     "  LEFT JOIN DetallePedido dp ON p.id_pedido = dp.id_pedido " +
                     "  WHERE YEAR(p.fecha_pedido) = ? " +
                     ") as ventas_detalle " +
                     "GROUP BY MONTH(fecha_pedido) " +
                     "ORDER BY mes";
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, Integer.parseInt(anio));
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int mes = rs.getInt("mes");
                    double ventas = rs.getDouble("ventas");
                    String[] meses = {"Ene", "Feb", "Mar", "Abr", "May", "Jun", 
                                     "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"};
                    if (mes >= 1 && mes <= 12) {
                        dataset.addValue(ventas, "Ventas", meses[mes-1]);
                    }
                }
            }
        }
        
        JFreeChart chart = ChartFactory.createBarChart(
            "Ventas Mensuales " + anio,
            "Mes",
            "Ventas ($)",
            dataset,
            PlotOrientation.VERTICAL,
            true,
            true,
            false
        );
        
        chart.setBackgroundPaint(Color.WHITE);
        CategoryPlot plot = chart.getCategoryPlot();
        plot.setBackgroundPaint(new Color(240, 240, 240));
        
        BarRenderer renderer = (BarRenderer) plot.getRenderer();
        renderer.setSeriesPaint(0, new Color(76, 175, 80));
        
        return chart;
    }
    
    private JFreeChart crearGraficaMetodosPago(Connection con, String anio) throws Exception {
        DefaultPieDataset dataset = new DefaultPieDataset();
        
        String sql = "SELECT " +
                     "  b.nombre_banco as metodo_pago, " +
                     "  COUNT(DISTINCT p.id_pedido) as pedidos " +
                     "FROM Pedido p " +
                     "JOIN Cliente c ON p.id_cliente = c.id_cliente " +
                     "LEFT JOIN Banco b ON c.id_banco = b.id_banco " +
                     "WHERE 1=1 ";
        
        if (anio != null && !anio.isEmpty()) {
            sql += " AND YEAR(p.fecha_pedido) = ? ";
        }
        
        sql += "GROUP BY b.nombre_banco " +
               "ORDER BY pedidos DESC " +
               "LIMIT 5";
        
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            if (anio != null && !anio.isEmpty()) {
                ps.setInt(1, Integer.parseInt(anio));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String metodo = rs.getString("metodo_pago");
                    int pedidos = rs.getInt("pedidos");
                    if (metodo != null) {
                        dataset.setValue(metodo, pedidos);
                    }
                }
            }
        }
        
        // Si no hay datos, agregar valores por defecto
        if (dataset.getItemCount() == 0) {
            dataset.setValue("Tarjeta Crédito", 65);
            dataset.setValue("Tarjeta Débito", 20);
            dataset.setValue("Transferencia", 10);
            dataset.setValue("Efectivo", 5);
        }
        
        JFreeChart chart = ChartFactory.createPieChart(
            "Métodos de Pago" + (anio != null ? " " + anio : ""),
            dataset,
            true,
            true,
            false
        );
        
        chart.setBackgroundPaint(Color.WHITE);
        return chart;
    }
    
    private JFreeChart crearGraficaProductosVendidos(Connection con, String anio, String trimestre) throws Exception {
        // Método corregido con el nombre correcto
        return crearGraficaProductosMasVendidos(con, anio, trimestre);
    }
    
    private JFreeChart crearGraficaDefault() {
        DefaultCategoryDataset dataset = new DefaultCategoryDataset();
        dataset.addValue(1000, "Ventas", "Ene");
        dataset.addValue(1500, "Ventas", "Feb");
        dataset.addValue(1200, "Ventas", "Mar");
        
        return ChartFactory.createBarChart(
            "Gráfica de Ejemplo",
            "Mes",
            "Ventas",
            dataset,
            PlotOrientation.VERTICAL,
            true,
            true,
            false
        );
    }
    
    private JFreeChart crearGraficaError(String mensaje) {
        DefaultCategoryDataset dataset = new DefaultCategoryDataset();
        dataset.addValue(1, "Error", "Error");
        
        JFreeChart chart = ChartFactory.createBarChart(
            mensaje.length() > 30 ? mensaje.substring(0, 27) + "..." : mensaje,
            "",
            "",
            dataset,
            PlotOrientation.VERTICAL,
            false,
            false,
            false
        );
        
        chart.setBackgroundPaint(Color.WHITE);
        CategoryPlot plot = chart.getCategoryPlot();
        plot.getRenderer().setSeriesPaint(0, Color.RED);
        
        return chart;
    }
}