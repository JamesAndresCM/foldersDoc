class FoldersController < ApplicationController
  before_action :set_folder, only: %i[show upload destroy remove_document]

  def index
    @folders = Folder.where(parent_id: nil).order(updated_at: :desc)
    @pagy, @folders = pagy_countless(@folders, items: 10)
  end

  def upload
    @folder.documents.attach(params[:document])
    render json: { status: "success", message: "Document uploaded successfully" }
  end

  def show
   @items = @folder.children + @folder.documents.includes(blob: :attachments).order(created_at: :desc)
   @pagy, @items = pagy_array(@items, items: 10)
  end

  def new
    @folder = Folder.new
    @folder.parent_id = params[:folder_id] if params[:folder_id].present?
    render partial: "modal_content",  formats: [:turbo_stream]
  end

  def create
    @folder = Folder.new(folder_params)

    respond_to do |format|
      if @folder.save
        format.html { 
          if @folder.parent_id.present?
            redirect_to folder_url(@folder.parent_id), notice: "Folder was successfully created." 
          else
            redirect_to folders_url, notice: "Folder was successfully created." 
          end

        }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @folder.destroy

    respond_to do |format|
      format.html { 
      if @folder.parent_id.present?
        redirect_to folder_url(@folder.parent_id), alert: "Folder was successfully destroyed."
      else
        redirect_to folders_url, alert: "Folder was successfully destroyed."
      end
      }
    end
  end

  def remove_document
    document = @folder.documents.find(params[:document_id])
    document.purge
    redirect_to folder_path(@folder), alert: "Document successfully removed!"
  end

  private
  
  def set_folder
    @folder = Folder.find_by_id(params[:id])
    redirect_to folders_url, alert: "Document not found" if @folder.nil?
  end

  def folder_params
    params.require(:folder).permit(:name, :parent_id, documents: [])
  end
end
