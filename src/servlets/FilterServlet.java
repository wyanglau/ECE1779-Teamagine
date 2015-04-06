package servlets;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import DAO.Constants_General;

/**
 * Servlet implementation class SortServlet
 */
public class FilterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public FilterServlet() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {

		String dates = (String) request
				.getParameter(Constants_General.FILTER_DATE_ID);
		String capacity = (String) request
				.getParameter(Constants_General.FILTER_CAPACITY_ID);
		String category = (String) request
				.getParameter(Constants_General.FILTER_CATEGORY_ID);

		/**
		 * Label Value
		 */
		if ((dates != null)
				&& (dates.equals(Constants_General.FILTER_DATE_DEFAULT))) {
			dates = null;
		}
		if ((capacity != null)
				&& (capacity.equals(Constants_General.FILTER_CAPACITY_DEFAULT))) {
			capacity = null;
		}
		if ((category != null)
				&& (category.equals(Constants_General.FILTER_CATEGORY_DEFAULT))) {
			category = null;
		}
		request.getSession().setAttribute(Constants_General.FILTER_DATE_ID,
				dates);
		request.getSession().setAttribute(Constants_General.FILTER_CAPACITY_ID,
				capacity);
		request.getSession().setAttribute(Constants_General.FILTER_CATEGORY_ID,
				category);
	}
}
