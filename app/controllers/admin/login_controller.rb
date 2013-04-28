class Admin::LoginController < LoginController
		
	def create 
		admin = Admin.find_by_email(params[:email])
		if admin && admin.authenticate(params[:password])
			session[:admin_id] = admin.id
			session[:username] = admin.username
			redirect_to admin_url, notice: "Logged in!"
		else
			redirect_to admin_url, notice: "You are unable to login!!"
		end
	end

	def destroy
		session[:admin_id] = nil
		redirect_to root_url, notice: "Logged Out!"
	end

	def new
		
	end

end