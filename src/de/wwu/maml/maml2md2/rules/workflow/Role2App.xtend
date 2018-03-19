package de.wwu.maml.maml2md2.rules.workflow

import de.wwu.maml.dsl.maml.Role
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.controller.ProcessElement2WorkflowElement
import de.wwu.md2.framework.mD2.App
import de.wwu.md2.framework.mD2.WorkflowElement
import de.wwu.md2.framework.mD2.WorkflowElementReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

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
				app.name = src.name + src.name
				app.appName = app.name
				
				app.workflowElements.addAll(src.processElements.map[pe |
					val wfeRef = createTargetElement(targetPackage.workflowElementReference) as WorkflowElementReference
					wfeRef.workflowElementReference = pe.getOrCreateCorrModelElement(ProcessElement2WorkflowElement.ruleID).targetElement as WorkflowElement
					// TODO startable
					
					return wfeRef
				])
				
//				src.processElements.forEach[pe |
//					// Create workflowElementEntry
//					val wfeEntryCorr = pe.getOrCreateCorrModelElement(ruleIDwfeEntry)
//					val entry = wfeEntryCorr.getOrCreateTargetElem(targetPackage.workflowElementEntry) as WorkflowElementEntry
//					
//					val wfeCorr = pe.getOrCreateCorrModelElement(ProcessElement2WorkflowElement.ruleID)
//					entry.workflowElement = wfeCorr.targetElement as WorkflowElement
//					
//					// TODO Dummy FireEventEnty
//					val fireEventEntry = createTargetElement(targetPackage.fireEventEntry) as FireEventEntry
//					val eventCorr = pe.getOrCreateCorrModelElement(ProcessElement2WorkflowElement.ruleIDworkflowEvent)
//					fireEventEntry.event = eventCorr.targetElement as WorkflowEvent // TODO
//					fireEventEntry.endWorkflow = true
//					entry.firedEvents.add(fireEventEntry)
//					
//					wfes.add(entry)
//				]
				
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