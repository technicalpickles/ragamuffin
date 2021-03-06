Java Servlets are the JEE way of doing anything web based. They are pretty easy to write. Here's short example to read a query parameter, and display it.


    import java.io.*;
    import javax.servlet.*;
    import javax.servlet.http.*;
    
    public class ExampleServlet extends HttpServlet {
      public void doGet(HttpServletRequest request, 
    	 HttpServletResponse response)
            throws ServletException, IOException
      {
        PrintWriter out = response.getWriter();
        String DATA = request.getParameter("DATA");
    
        if(DATA != null){
          out.println(DATA);
        } else {
          out.println("No text entered.");
        }
        out.close();
      }
    }


And don't forget to set it up in web.xml:


    <web-app xmlns="http://java.sun.com/xml/ns/j2ee" version="2.4"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http:/java.sun.com/dtd/web-app_2_3.dtd">
      <servlet>
        <servlet-name>example</servlet-name>
        <servlet-class>ExampleServlet</servlet-class>
      </servlet>
    
      <servlet-mapping>
        <servlet-name>example</servlet-name>
        <url-pattern>/example</url-pattern>
      </servlet-mapping>
    </web-app>


All pretty straight forward. What if we could harness this technique in the Ruby world? Rack is a minimal framework to make talking to a Ruby webserver nicer, and is pretty flexible and great to build frameworks on top of. Imagine if you would, an API like Java Servlets... but implemented on rack....

I present to you... racklets! Let's start by making a new ruby file, and putting it in a well known load path: WEB-INF/lib. So, we'll make WEB-INF/lib/example_racklet.rb :

    require 'ragamuffin'
    class ExampleRacklet < Ragamuffin::Racklet
      def do_get(request, response)
        data = request.params['DATA']
        if data
          response.write data
        else
          response.write 'No data'
        end
      end
    end

Next we need a web.xml to tell racklets what to load, and what urls to map it. This is kept in WEB-INF/web.xml:

    <web-app>
      <racklet>
        <racklet-name>example</racklet-name>
        <racklet-class>ParamRacklet</racklet-class>
      </racklet>
    
      <racklet-mapping>
        <racklet-name>example</racklet-name>
        <url-pattern>/example</url-pattern>
      </racklet-mapping>
    </web-app>

Since we're on rack, you'll want a config.ru to run our ragamuffin web application.

    require 'ragamuffin'
    run Ragamuffin::WebApplication.new


This handles loading up the web.xml and updating $LOAD_PATH to include the WEB-INF/lib directory. So now we're in business to something like shotgun to run our server:

    $ shotgun 
    == Shotgun starting Rack::Handler::Mongrel on localhost:9393

Alternatively, you can use the included `ragamuffin` script to run it without a config.ru file.

    $ bin/ragamuffin 
    == Ragamuffin starting Rack::Handler::Mongrel on localhost:9393
    
Now go ahead and browse to http://localhost:9393/example and you'll see:

    No Data

Give it the DATA parameter, and you'll see it displayed, ie http://localhost:9393/example?DATA=Hello%20World

    Hello World

