<%@page import="org.codehaus.jackson.map.ser.ArraySerializers.IntArraySerializer"%>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.amazonaws.*" %>
<%@ page import="com.amazonaws.auth.*" %>
<%@ page import="com.amazonaws.services.ec2.*" %>
<%@ page import="com.amazonaws.services.ec2.model.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="org.apache.tools.ant.*" %>

<%! // Share the client objects across threads to
    // avoid creating new clients for each web request
    private AmazonEC2      ec2;
    BuildLogger buildLogger;
 %>

<%
    if (request.getMethod().equals("HEAD")) return;

	boolean check = false;
    boolean isfile = false;
    boolean isAWS = false;
    String getCheck = request.getParameter("check");
	String getAWS = request.getParameter("aws");
	String getWalkthrough = ""; 
	getWalkthrough = request.getParameter("walkthrough");
	if( getCheck != null)
		if( getCheck.equalsIgnoreCase("check"))
			check = true;
	
	if(getWalkthrough != null)
	{
		if( getWalkthrough.equalsIgnoreCase("walkthrough"))
		{
			isfile = true;
		    isAWS = true;
		}
	}
	else
	{
    	try
        {
        	File source = new File(getAWS);
        	AWSCredentials credentials = new PropertiesCredentials(source);
		    ec2 = new AmazonEC2Client(credentials);
		    isfile = true;
        }
       	catch(Exception ex)
	    {
	    	isfile = false;
	    }
        try
	    {	
		    ec2.describeInstances().getReservations();
			isAWS = true;
	    }
	    catch(Exception ex)
	    {
	    	isAWS = false;	
	    }
	}
%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8">
    <title>Upload files!</title>
    <link rel="stylesheet" href="styles/styles.css" type="text/css" media="screen">
</head>
<body>
    <div id="content" class="container">
        

        <div class="section grid grid5 gridlast ec2">
        <%
      	  	
        	if(!check)
        		out.write("Please access the page through the <a href='index.jsp'>index page</a>");
        	else if(!isfile)
    			out.write("AWS Credentials file path is incorrect. Please retry from the <a href='index.jsp'>index page</a>");
        	else if(!isAWS)
    			out.write("AWS Credentials incorrect. Please retry from the <a href='index.jsp'>index page</a>");
        	
        	else
        	{
	            /*Find out the operating system*/
	                   boolean osIsNux = false;
	                   if(System.getProperty("os.name").toLowerCase().contains("nux")||System.getProperty("os.name").toLowerCase().contains("nix"))
	                	   osIsNux = true;
	       %>
	            <h2>Amazon EC2 Instances:</h2>
	            <FORM ACTION="upload.jsp" METHOD=POST>
	            
	            <ul>
	            <% for (Reservation reservation : ec2.describeInstances().getReservations()) 
	            	{ %>
	                	<% for (Instance instance : reservation.getInstances()) 
	                		{  %>
	                   		<li> <% 
	                   		out.println(instance.getInstanceId()); %> - 
	                   	<% 	for(com.amazonaws.services.ec2.model.Tag  tag :instance.getTags())
	                   		{
	                   			
	                	   		if(instance.getState().getName().equals("running")) 
	                	   		{
	           						if(tag.getKey().equals("Name"))
	           						%> <font color="green"><% out.println(tag.getValue()); %>
	           					<select name = "<%=tag.getValue()%>">
	  							<option value="Do Not Upload">Do Not Upload</option>
	  							<option value="Upload">Upload</option>
	  							</select>
	  							<input type="file" name="<% out.write(tag.getValue()+"_"+instance.getPublicDnsName().toString()); %>" />
	  							<input type="hidden" name ="backup" value="<% out.write(tag.getValue()+"_"+instance.getPublicDnsName().toString()); %>" />
	  							
	  							<select name = "<%=instance.getInstanceId()%>">
	  							<option value="action">Action</option>
	  							<option value="restart">Restart</option>
	  							<option value="stop">Stop</option>
	  							</select>
	  						<%	} %></font>		
	                	 <%  	           			 
	           			 		if(!instance.getState().getName().equals("running")) 
	           			 		{
	           						if(tag.getKey().equals("Name"))
	           						%> <font color="red"><% out.println(tag.getValue());
	           						
	           					
	           			 	%> <select name = "<%=instance.getInstanceId()%>">
	  							<option value="action">Action</option>
	  							<option value="start">Start</option>	  							
	  							</select></font>
	  						<%	} %>
	           			 </li>
	                <% 		}
	                	} %>
	            <% } %>
	            </ul>
	            <% if(request.getParameter("path") == null ) { %>
	            Source Path : <input type="text" name="path" value="/home/anchoo/Documents/" style="margin-left:32px;"/>
	            
	            
	            <% } %>
	            <% if(request.getParameter("path") != null ) { %>
	            Source Path : <input type="text" name="path" value="<%= request.getParameter("path") %>" style="margin-left:32px;"/>
	            
	            <% } %>
	            <% if (request.getParameter("ec2") == null) { %>
	            	<input type="checkbox" name="ec2" value="ec2">This is the EC2 instance
	            <% } else { %>
	            <input type="checkbox" name="ec2" value="ec2" checked>This is the EC2 instance
	            <% 	}  %>
	            <br />
	             <% if(request.getParameter("dest") == null ) { %>
	            Destination Path : <input type="text" name="dest" value="/home/ec2-user/test/"/><br/>
	            <% } %>
	            <% if(request.getParameter("dest") != null ) { %>
	            Destination Path : <input type="text" name="dest" value="<%= request.getParameter("dest") %>"/><br/>
	            <% } %>
	            <% if(request.getParameter("key") == null ) { %>
	            Key : <input type="text" name="key" value="/home/anchoo/data/nbim/key/nbim.pem" style="margin-left:72px;"/><br/>
	            <% } %>
	            <% if(request.getParameter("key") != null ) { %>
	            Key : <input type="text" name="key" value="<%= request.getParameter("key") %>" style="margin-left:72px;"/><br/>
	            <% } %>
	            
	            <% if(request.getParameter("pscp") == null && !osIsNux) { %>
	            PSCP Path : <input type="text" name="pscp" value="E:\Putty\" style="margin-left:43px;"/><br/>
	             <% } %>
	             
	             <% if(request.getParameter("pscp") != null && !osIsNux) { %>
	            	PSCP Path : <input type="text" name="pscp" value="<%= request.getParameter("pscp") %>" style="margin-left:43px;"/><br/>
	             <% } %>
				<INPUT TYPE="hidden" VALUE="<%= getCheck %>" name="check"/>
				<INPUT TYPE="hidden" VALUE="<%= getAWS %>" name="aws" />
				<INPUT TYPE="hidden" VALUE="walkthrough" name="walkthrough" />
	             <INPUT TYPE=SUBMIT VALUE=Submit />
	             <INPUT TYPE=SUBMIT VALUE=Reload />
	            </FORM>
	            <br />
	           <a href='index.jsp'>Click here</a> to go back to the main page and upload a new key!
	        </div>
	    </div>
	    <div id="content" class="container">
	    <B>Uploaded Content</B><BR>
	 <TABLE>
	<%  Enumeration parameters = request.getParameterNames();
	    Enumeration realParam = request.getParameterNames();
	    ArrayList<String> uploadI = new ArrayList<String>();
	    ArrayList<String[]> params = new ArrayList<String[]>();
	    ArrayList<String> start = new ArrayList<String>();
	    ArrayList<String> shutdown = new ArrayList<String>();
	    ArrayList<String> restart = new ArrayList<String>();
	    String key = "";
	    String dest = "";
	    String path = "";
	    String pscp = "";
	    boolean ec2Bool = false;
	    while(parameters.hasMoreElements())
	    {
	        	 String parameterName = (String)parameters.nextElement();
	        	if(request.getParameter(parameterName).equals("Upload"))
	        	{
	         		String parameterValue = request.getParameter(parameterName);
	         		uploadI.add(parameterName);
	         	 }
	        	if(request.getParameter(parameterName).equals("start"))
	        	{
	         		String parameterValue = request.getParameter(parameterName);
	         		start.add(parameterName);
	         	 }
	        	if(request.getParameter(parameterName).equals("restart"))
	        	{
	         		String parameterValue = request.getParameter(parameterName);
	         		restart.add(parameterName);
	         	 }
	        	if(request.getParameter(parameterName).equals("stop"))
	        	{
	         		String parameterValue = request.getParameter(parameterName);
	         		shutdown.add(parameterName);
	         	 }
	        	if( parameterName.equals("key"))
	        	{
	        		key = request.getParameter(parameterName); 
	        	}
	        	
	        	else if( parameterName.equals("dest"))
	        	{
	        		dest = request.getParameter(parameterName); 
	        	}
	        	
	        	else if( parameterName.equals("path"))
	        	{
	        		path = request.getParameter(parameterName); 
	        	}
	        	else if( parameterName.equals("pscp"))
	        	{
	        		pscp = request.getParameter(parameterName); 
	        	}
	        	else if( parameterName.equals("ec2"))
	        	{
	        		if( request.getParameter(parameterName).contains("ec2") )
	        		{
	        			ec2Bool=true;
	        		}
	        		
	        	}
	        	
	     }%>
	     
	   <% 
	   
	   			if(start.size() > 0)
	   			{
		   		    StartInstancesRequest startRequest = new StartInstancesRequest().withInstanceIds(start);
		   		    StartInstancesResult startResult = ec2.startInstances(startRequest);
		   		    List<InstanceStateChange> startStateChangeList = startResult.getStartingInstances();
	   			}
	   		 	for(String instanceID : start ) 
	   		    	out.write("<br />Starting instance '" + instanceID + "':");
   			
	   
	   		 	if(restart.size() > 0)
	   			{
		   			RebootInstancesRequest restartRequest = new RebootInstancesRequest().withInstanceIds(restart);
		   			ec2.rebootInstances(restartRequest);	   		    
	   			}
	   		    
	   		    
		   		for(String instanceID : restart )
		   			out.write("<br />Restarting instance '" + instanceID + "':");
	   
		   		
				if(shutdown.size() > 0 )
				{
		   		    StopInstancesRequest stopRequest = new StopInstancesRequest().withInstanceIds(shutdown);
		   		 	StopInstancesResult  StoptResult = ec2.stopInstances(stopRequest);
		   		    List<InstanceStateChange> stopStateChangeList = StoptResult.getStoppingInstances();
				}
				
		   		for(String instanceID : shutdown )
		  			out.write("<br />Shutting down instance "+instanceID);
			
	   
	   		while(realParam.hasMoreElements()){ 
		   	String parameterName = (String)realParam.nextElement();
		    
		   for(String instances : uploadI )
	    	{
			   
			   
	    		if (parameterName.contains(instances) && parameterName.contains("ec2"))
	    		{
	    			String []temp = new String[3];
	    			temp[0] = parameterName.replaceAll(instances+"_", "");
	    			temp[1] = request.getParameter(parameterName); 
	    			temp[2] = instances;
	    			params.add(temp);
	    		}
	    		//If request asks to transfer from amazon as source to local machine
	    		if (request.getParameter(parameterName).contains(instances) && request.getParameter(parameterName).contains("ec2") && ec2Bool)
	    		{
	    			String []temp = new String[3];
	    			temp[0] = request.getParameter(parameterName).replaceAll(instances+"_", "");
	    			temp[1] = request.getParameter("path"); 
	    			temp[2] = instances;
	    			params.add(temp);
	    		}
	    	}
	   }
	   %>
	    
	    <%
	    for(String[] param : params )
	    {
	    	
	    	String command = ""; 
	    	if(osIsNux)
	    	{
	    		if(ec2Bool)
	    			command = "scp -o StrictHostKeyChecking=no -i "+key+" ec2-user@"+param[0]+":"+path+" "+dest;
	    		else
	    			command = "scp -o StrictHostKeyChecking=no -i "+key+" "+path+param[1]+" ec2-user@"+param[0]+":"+dest;
	    	}
	    	else
	    	{
	    		if(ec2Bool)
	    			command = "cmd.exe /c echo n|"+"\""+pscp+"pscp\""+ " -i \""+key+"\" -r  ec2-user@"+param[0]+":"+path+" \""+dest+"\"";
	    		else
	    			command = "cmd.exe /c echo n|"+"\""+pscp+"pscp\""+ " -i \""+key+"\" -r  \""+path+param[1]+"\" ec2-user@"+param[0]+":"+dest;
	    	}
	    	System.out.println(command);
	    	Process p;
	    	%>
			 <TR>
	        <TD><%= param[2] %> - </TD>
	        <TD><%= param[1] %></TD>
	        <TD><font color="green"> :- Uploaded</font></TD>
	        <%   	
	        		//p = Runtime.getRuntime().exec(command); 
	        		
	       		try {
	            String line;
	            p = Runtime.getRuntime().exec(command);
	            BufferedReader bri = new BufferedReader
	              (new InputStreamReader(p.getInputStream()));
	            BufferedReader bre = new BufferedReader
	              (new InputStreamReader(p.getErrorStream()));
	            while ((line = bri.readLine()) != null) {
	              System.out.println(param[2]+" - "+line);
	            }
	            bri.close();
	            while ((line = bre.readLine()) != null) {
	              System.out.println(param[2]+" - "+line);
	            }
	            bre.close();
	            p.waitFor();
	            //System.out.println("Done.");
	          }
	          catch (Exception err) {
	            err.printStackTrace();
	          }
	%>
	        </TR>		
	<%
	    }	    
	    %>
	    
	 </TABLE>
	    </div>
	    <% } %>
</body>
</html>