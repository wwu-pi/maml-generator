package de.wwu.maml.maml2md2.util

import de.wwu.md2.framework.mD2.Controller
import de.wwu.md2.framework.mD2.MD2Model
import de.wwu.md2.framework.mD2.Model
import de.wwu.md2.framework.mD2.View
import de.wwu.md2.framework.mD2.Workflow
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

class ResourceHelper {
	
	public static final String TARGET_MD2_MODEL_RESOURCE = "targetModel.md2"
	public static final String TARGET_MD2_VIEW_RESOURCE = "targetView.md2"
	public static final String TARGET_MD2_CONTROLLER_RESOURCE = "targetController.md2"
	public static final String TARGET_MD2_WORKFLOW_RESOURCE = "targetWorkflow.md2"
	
	static def getMD2Resource(ResourceSet set){
		set.resources.get(0)
	}
	
	static def getMAMLResource(ResourceSet set){
		set.resources.get(0)
	}
	
	static def getMD2ModelContainer(Resource res){
		res.contents.filter[it instanceof MD2Model && (it as MD2Model).modelLayer instanceof Model]?.get(0)
	}
	
	static def getMD2ViewContainer(Resource res){
		res.contents.filter[it instanceof MD2Model && (it as MD2Model).modelLayer instanceof View]?.get(0)
	}
	
	static def getMD2ControllerContainer(Resource res){
		res.contents.filter[it instanceof MD2Model && (it as MD2Model).modelLayer instanceof Controller]?.get(0)
	}
	
	static def getMD2WorkflowContainer(Resource res){
		res.contents.filter[it instanceof MD2Model && (it as MD2Model).modelLayer instanceof Workflow]?.get(0)
	}
}