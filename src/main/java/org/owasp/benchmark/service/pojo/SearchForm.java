package customerService.utilities;

import data.DataController;
import data.LoginModule;
import html.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.*;

import data.RowSet;
import data.UserInfo;
import utilities.DataFunctions;
import utilities.TagFunctions;

public class SearchForm extends DynamicDataForm 
{
	
	private UserInfo userInfo;
	private ArrayList fields = new ArrayList();
	private int rowNumber=0;
	
	public SearchForm(UserInfo userInfo,LinkedHashMap params)
	{
		this.userInfo = userInfo;
		int currentOffset=0;
		this.setLoginModule(userInfo.getLoginModule());
		int searchType = Integer.parseInt(params.get("servicing_search_type").toString());
		String searchValue = params.get("servicing_search_value").toString();
		int searchPaidOff = Integer.parseInt(params.get("servicing_search_paidoff").toString());
		Object count = params.get("servicing_search_next_offset");
		if (count!=null) {
			currentOffset=Integer.parseInt(count.toString());
		}
		runStatement("exec databaseName.schema.storedProcName "+searchType+",'"+searchValue+"'", getLoginModule());
		this.setSql("exec databaseName.schema.storedProcName ?,?,?,?");
		this.setPreparedStatementArguments(searchType,searchValue,searchPaidOff,currentOffset);
		String[] key = {"account_number"};
		this.setKey(key);
		this.setFormTitle(
				"Search Results (Starting at Row:  "+currentOffset+") "+
				TagFunctions.makeButton("servicingNext100SearchResult","Get Next 100","false","doServicingSearch()").getHTML()
		);
		this.setTableName("");
		this.setHeight(460);
		this.setWidth(825);
		this.setClientSideSortable(true);
		this.setInputArray(new ArrayList());
		this.setViewToEditFunction("viewToAccountLookup");
		this.setReadOnly(true);
		ArrayList input_array = new ArrayList();
		input_array.add(new Tag("input","type=hidden name=servicing_search_next_offset value=" + (currentOffset+100)));
		this.setInputArray(input_array);
		String[] key1 = {"id"};
		RowSet rs = new RowSet();
		String sError = rs.setData("exec notedb.fnba.servicing_search_fetch -2", this.getLoginModule(),key1);
		for (int i = 0; i < rs.getRowCount(); i++) {
			fields.add(rs.getData(i,1).toString());
		}
	}
	
	protected ArrayList getDisplayColumns() {
		return fields;
	}
	
	public LinkedHashMap getCellTemplates()
	{	
		rowNumber++;
		LinkedHashMap templates = this.getTemplates();
		Tag td = (Tag)templates.get("acct");
		if (rowNumber%2==0){
			for (Iterator iter = templates.keySet().iterator(); iter.hasNext();) {
				String key = (String) iter.next();
				Tag tdtmp = (Tag)templates.get(key);
				tdtmp.setClassName("dataTable2");
			}
			td.setClassName("actionCell2");
		} else {
			td.setClassName("actionCell");
		}
		td.setOnClick("viewToAccountLookup('"+getFormName()+"',this.id.substring(this.id.lastIndexOf('_')+1));");
		return templates;
	}

	private String runStatement(String s, LoginModule loginModule) {
		String sError = "";
		try (Connection con = loginModule.getConnection();
			 PreparedStatement ps = con.prepareStatement(s)) {
			ps.executeUpdate();
		} catch (Exception e) {
			sError = sError + " | " + e.getMessage();
		}
		return sError;
	}
	
}
