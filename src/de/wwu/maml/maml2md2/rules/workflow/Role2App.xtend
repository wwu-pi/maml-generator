package de.wwu.maml.maml2md2.rules.workflow

import de.wwu.maml.dsl.maml.Role
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.controller.ProcessElement2WorkflowElement
import de.wwu.md2.framework.mD2.App
import de.wwu.md2.framework.mD2.WorkflowElement
import de.wwu.md2.framework.mD2.WorkflowElementReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

import static extension de.wwu.maml.maml2md2.util.MamlHelper.*
import de.wwu.maml.dsl.maml.UseCase

class Role2App extends Elem2Elem {
	
	public static final String ruleID = "Role->App"
	//public static final String ruleIDwfeEntry = "ProcessElement->WorkflowElementEntry"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	 
	/* 
	 * Dependencies:
	 * - WorkflowElement
	 */
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(Role))
			.forEach[src |
				val corr = src.getOrCreateCorrModelElement(ruleID)
				val app = corr.getOrCreateTargetElem(targetPackage.app) as App
				app.name = src.toUniqueName(src.name + "App")
				app.appName = app.name
				
				app.workflowElements.addAll(src.processElements.map[pe |
					val wfeRef = createTargetElement(targetPackage.workflowElementReference) as WorkflowElementReference
					wfeRef.workflowElementReference = pe.getOrCreateCorrModelElement(ProcessElement2WorkflowElement.ruleID).targetElement as WorkflowElement
					wfeRef.startable = pe.firstInteractionProcessElement
					if(wfeRef.startable) wfeRef.alias = (pe.eContainer as UseCase).title
					
					return wfeRef
				])
				
				MD2Workflow.apps.add(app)
			]
	}
	
	override def targetToSource() {
//		targetModel.allContents.filter(typeof(de.wwu.md2.framework.mD2.Model))
//			.forEach[m |
//				val corr = m.getOrCreateCorrModelElement(ruleID)
//				val source = corr.findOrCreateSourceElemOfType(sourcePackage.model)
//				sourceModel.MAMLResource.contents += source
//			]
	}
}