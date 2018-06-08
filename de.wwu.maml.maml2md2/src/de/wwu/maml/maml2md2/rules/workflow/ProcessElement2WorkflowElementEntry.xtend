package de.wwu.maml.maml2md2.rules.workflow

import de.wwu.maml.dsl.maml.InteractionProcessElement
import de.wwu.maml.maml2md2.rules.Elem2Elem
import de.wwu.maml.maml2md2.rules.controller.ProcessElement2WorkflowElement
import de.wwu.md2.framework.mD2.FireEventEntry
import de.wwu.md2.framework.mD2.WorkflowElement
import de.wwu.md2.framework.mD2.WorkflowElementEntry
import de.wwu.md2.framework.mD2.WorkflowEvent
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet

import static extension de.wwu.maml.maml2md2.util.MamlHelper.*

class ProcessElement2WorkflowElementEntry extends Elem2Elem {
	
	public static final String ruleID = "ProcessElement->WorkflowElementEntry"
	
	new(ResourceSet src, ResourceSet trgt, Resource corr) {
		super(src, trgt, corr)
	}
	 
	/* 
	 * Dependencies:
	 * - WorkflowElement
	 * - WorkflowEvent
	 */
	override def sourceToTarget() {
		sourceModel.allContents.filter(typeof(InteractionProcessElement))
			.forEach[src |
				// Find subsequent steps and create workflow events + view actions
				val nextSteps = getNextSteps(src)
				
				// Create workflowElementEntry
				val entry = createTargetElement(targetPackage.workflowElementEntry) as WorkflowElementEntry
				val wfeCorr = src.getOrCreateCorrModelElement(ProcessElement2WorkflowElement.ruleID)
				entry.workflowElement = wfeCorr.targetElement as WorkflowElement
						
				if(nextSteps.size == 0){
					// Final step -> End workflow
					
					// Create FireEventEnty
					val fireEventEntry = createTargetElement(targetPackage.fireEventEntry) as FireEventEntry
					val eventCorr = src.getOrCreateCorrModelElement(ProcessElement2WorkflowElement.ruleIDworkflowEvent)
					fireEventEntry.event = eventCorr.targetElement as WorkflowEvent 
					fireEventEntry.endWorkflow = true
					entry.firedEvents.add(fireEventEntry)
					
				} else {
					// Has subsequent steps -> generate starting workflow entries
					nextSteps.forEach[
						val targetWfe = it.targetProcessFlowElement.getOrCreateCorrModelElement(ProcessElement2WorkflowElement.ruleID).targetElement as WorkflowElement
						val combinationSuffix = "[->" + targetWfe.name + "]" // Ensure unique name for corrModel
						
						// Create FireEventEnty
						val fireEventEntry = createTargetElement(targetPackage.fireEventEntry) as FireEventEntry
						val eventCorr = src.getOrCreateCorrModelElement(ProcessElement2WorkflowElement.ruleIDworkflowEvent + combinationSuffix)
						fireEventEntry.event = eventCorr.targetElement as WorkflowEvent 
						fireEventEntry.startedWorkflowElement = targetWfe
						entry.firedEvents.add(fireEventEntry)
					]
				}
				
				MD2Workflow.workflowElementEntries.add(entry)
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