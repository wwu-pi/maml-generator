package de.wwu.maml.maml2md2.util

import org.eclipse.emf.ecore.resource.ResourceSet
import de.wwu.maml.maml2md2.rules.Elem2Elem

class ResourceHelper {
	
	public static final String TARGET_MD2_MODEL_RESOURCE = "targetModel.md2"
	public static final String TARGET_MD2_VIEW_RESOURCE = "targetView.md2"
	public static final String TARGET_MD2_CONTROLLER_RESOURCE = "targetController.md2"
	public static final String TARGET_MD2_WORKFLOW_RESOURCE = "targetWorkflow.md2"
	
	static def getMD2ModelResource(ResourceSet set){
		set.resources.filter[it.URI.lastSegment == TARGET_MD2_MODEL_RESOURCE]?.head
	}
	
	static def getMD2ViewResource(ResourceSet set){
		set.resources.filter[it.URI.lastSegment == TARGET_MD2_VIEW_RESOURCE]?.head
	}
	
	static def getMD2ControllerResource(ResourceSet set){
		set.resources.filter[it.URI.lastSegment == TARGET_MD2_CONTROLLER_RESOURCE]?.head
	}
	
	static def getMD2WorkflowResource(ResourceSet set){
		set.resources.filter[it.URI.lastSegment == TARGET_MD2_WORKFLOW_RESOURCE]?.head
	}
	
	static def getMAMLResource(ResourceSet set){
		set.resources.get(0)
	}
}